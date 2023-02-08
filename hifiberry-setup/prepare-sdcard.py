#!/usr/bin/python3
import sys
import os
import subprocess

SUBSTITUTIONS={
    "${SNAPCAST_SERVER}": "snapcast.jonh.net",
    "${WPA_SSID}": "wifi-name",
    "${WPA_PSK}": "wifi-password",
}

try:
    blockdevice = sys.argv[1]
    assert blockdevice.startswith("/dev")
    pitype = sys.argv[2]
    assert pitype in ["pi3", "pi4"]
except Exception as ex:
    #sys.stderr.write(str(ex)+"\n")
    sys.stderr.write(f"Usage: {sys.argv[0]} </dev/sdx> <pi3|pi4>\n")
    sys.exit(1)

if not os.path.exists("pubkey"):
    sys.stderr.write("./pubkey should be an ssh public key. Example:\n")
    sys.stderr.write("ln -s ~/.ssh/id_rsa.pub pubkey\n")
    sys.exit(1)

mntpoint="./mnthifiberry"
if os.path.exists(mntpoint):
    sys.stderr.write(f"Mount point {mntpoint} already exists. Remove.\n")
    sys.exit(1)

def load_hifiberry_to_sdcard():
    mountout = subprocess.run("mount", capture_output=True).stdout.decode("utf-8")
    if blockdevice in mountout:
        sys.stderr.write(f"{blockdevice} already mounted. Unmount and try again.\n")
        sys.exit(1)

    zipfile = f"images-deleteme/hifiberryos-{pitype}.zip"

    zipdirout = subprocess.run(["unzip", "-l", zipfile], capture_output=True).stdout.decode("utf-8")
    lines = zipdirout.split('\n')
    assert "1 file" in lines[-2]    # expecting hifiberryos zip to contain exactly one file.
    imglines = [l for l in lines if l.endswith(".img")]
    assert(len(imglines)==1)
    imgname = imglines[0].split()[-1]
    print(imgname)

    # Unzip img to stdout and pipe that to dd to fill the sdcard
    unzipPipe = subprocess.Popen(["unzip", "-qqc", zipfile, imgname], stdout=subprocess.PIPE)
    ddout = subprocess.check_output(["dd", f"of={blockdevice}", "status=progress"], stdin = unzipPipe.stdout)
    unzipPipe.wait()

def apply_patches():
    # Assume rootfs is partition 2
    partitiondevice = blockdevice + "2"
    os.mkdir(mntpoint)
    patches = open("local-deltas/patches").read()
    for k,v in SUBSTITUTIONS.items():
        patches = patches.replace(k, v)
    applied_patches_fn = "/tmp/patches-applied"
    fp = open(applied_patches_fn, "w")
    fp.write(patches)
    fp.close()
    subprocess.check_output(["mount", partitiondevice, mntpoint])
    subprocess.check_output(["patch", "-p", "1"], stdin=open(applied_patches_fn), cwd=mntpoint)
    subprocess.check_output(["cp", "-r", "local-deltas/copyin/.", mntpoint+"/."])
    subprocess.check_output(["mkdir", "-p", f"{mntpoint}/root/.ssh"])
    subprocess.check_output(["chmod", "0700", f"{mntpoint}/root/.ssh"])
    subprocess.check_output(["cp", "pubkey", f"{mntpoint}/root/.ssh/authorized_keys"])
    subprocess.check_output(["chmod", "0600", f"{mntpoint}/root/.ssh/authorized_keys"])
    subprocess.check_output(["umount", partitiondevice])
    subprocess.check_output(["sync"])
    os.rmdir(mntpoint)

load_hifiberry_to_sdcard()
apply_patches()
