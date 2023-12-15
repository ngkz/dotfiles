#!@bash@/bin/bash
set -euo pipefail

export PATH=/empty
for i in @path@; do PATH=$PATH:$i/bin; done

tmpdir=$(mktemp -d -t grub-secureboot.XXXXXXXX)
trap "rm -rf $tmpdir" EXIT

passwordHash=$tmpdir/password-hash
secureBootCert=$tmpdir/db.crt
secureBootKey=$tmpdir/db.key
gpgPrivKey=$tmpdir/grub.key
gpgPubKey=$tmpdir/grub.gpg
initialCfg=$tmpdir/initial.cfg
tmpEFI=$tmpdir/boot.efi
fingerprintstate=@boot@/grub/sigstate

# agenix secrets are not yet available when installing bootloader
# so we need to decrypt secrets manually

# input output
decrypt() {
    echo >"$2"
    chmod 400 "$2"
    @age@ --decrypt @ageIdentities@ -o "$2" "$1"
}

decrypt @passwordHashSecret@ "$passwordHash"
decrypt @secureBootCertSecret@ "$secureBootCert"
decrypt @secureBootKeySecret@ "$secureBootKey"
decrypt @gpgPrivKeySecret@ "$gpgPrivKey"

cat <<EOS >"$initialCfg"
# Enforce that all loaded files must have a valid signature.
set check_signatures=enforce
export check_signatures

# Disable unautiorized access to CLI and menu entries except default one
set superusers="root"
export superusers
password_pbkdf2 root $(<"$passwordHash")

# NOTE: We export check_signatures/superusers so they are available in all
# further contexts to ensure the password check is always enforced.

# First partition on first disk, most likely EFI system partition. Set it here
# as fallback in case the search doesn't find the given UUID.
set root='hd0,gpt1'
search --no-floppy --fs-uuid --set=root $(findmnt -fno UUID /boot)
# example, see below: search --no-floppy --fs-uuid --set=root 891F-FF86

configfile /grub/grub.cfg

# Without this we provide the attacker with a rescue shell if they just press
# <return> twice.
echo /boot/grub/grub.cfg did not boot the system but returned to initial.cfg.
echo Rebooting the system in 10 seconds.
sleep 10
reboot
EOS

export GNUPGHOME=$tmpdir/gnupg
mkdir "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

gpg --import "$gpgPrivKey" &>/dev/null

fingerprint=$(gpg --list-keys --with-fingerprint --with-colons | awk -F: '/^fpr/ { print $10 }')

if [[ ! -e "$fingerprintstate" ]] || [[ "$(cat <$fingerprintstate 2>/dev/null)" != "$fingerprint" ]]; then
    gpgKeyChanged=1
else
    gpgKeyChanged=
fi

gpg --detach-sign "$initialCfg" >/dev/null
gpg --export >"$gpgPubKey"

for kernel in /boot/kernels/*-bzImage; do
    if ! sbverify --cert "$secureBootCert" "$kernel" &>/dev/null; then
        echo "secure boot signing $kernel"
        sbsign --cert "$secureBootCert" --key "$secureBootKey" \
                --output "$kernel.signed" "$kernel" &>/dev/null
        mv "$kernel.signed" "$kernel"
    fi
done

# restore kernel signatures saved at extraPrepareConfig
[[ -n "$(shopt -s nullglob; echo /boot/kernels.bak/*)" ]] && mv @boot@/kernels.bak/* @boot@/kernels
rmdir @boot@/kernels.bak

find @boot@ ! -path "@esp@/EFI/*" ! -path "$fingerprintstate" ! -path "@boot@/grub/state" -type f | while read -r path; do
    if [[ "$path" =~ (.*).sig$ ]]; then
        if [[ ! -e "${BASH_REMATCH[1]}" ]]; then
            # file removed
            rm -f "$path"
        fi
    elif [[ -n "$gpgKeyChanged" ]] || [[ ! -e "${path}.sig" ]] || [[ "$(stat -c "%Y" "$path")" -gt "$(stat -c "%Y" "${path}.sig")" ]]; then
        # key changed or not signed or file changed
        echo "pgp signing $path"
        gpg --yes --detach-sign "$path"
    fi
done

if [[ ! -e "$fingerprintstate" ]] || [[ "$(cat <$fingerprintstate 2>/dev/null)" != "$fingerprint" ]]; then
    echo "$fingerprint" >"$fingerprintstate"
fi

grub-mkstandalone \
    --format @grubTarget@ \
    --modules "part_$(grub-probe -t partmap @boot@)
               $(grub-probe -t abstraction @boot@)
               $(grub-probe -t fs @boot@)
               pgp gcry_sha512 gcry_rsa
               password_pbkdf2
               configfile
               echo reboot sleep
               search search_fs_uuid" \
    --pubkey "$gpgPubKey" \
    --disable-shim-lock \
    --output "$tmpEFI" \
    "boot/grub/grub.cfg=$initialCfg" \
    "boot/grub/grub.cfg.sig=${initialCfg}.sig"

sbsign --cert "$secureBootCert" --key "$secureBootKey" \
        --output @efiFile@ "$tmpEFI" &>/dev/null
