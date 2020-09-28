import os
import sys
import subprocess

split = int(sys.argv[2])
device = sys.argv[1]
step = int(100/split)
storage = sys.argv[3]
partition_cmd = 'sudo parted -s --align optimal {} -- mklabel gpt'.format(
    device)
fs_cmd = []
mn_cmd = []
tb_cmd = []
names = [int(i.replace(storage,'')) for i in os.listdir('/media') if i.startswith(storage)]
names.append(0)
start = max(names)

for i, (s, e) in enumerate(zip(range(0, 100, step), range(step, 100+step, step))):
    partition_cmd += ' mkpart primary ext4 {}% {}%'.format(s, e)
    fs_cmd.append(
        'sudo mkfs.ext4 -L data-{}-{} {}{}'.format(storage, i+1, device, i+1))
    mn_cmd.append('sudo mkdir -p /media/{}{}'.format(storage, start+i+1))
    tb_cmd.append(
        '{}{} /media/{}{} ext4 defaults 0 0'.format(device, start+i+1, storage, i+1))

print('# running', partition_cmd)
subprocess.Popen(
    partition_cmd.split(' ')).communicate()

print('# running', fs_cmd)
for c in fs_cmd:
    subprocess.Popen(
        c.split(' ')).communicate()

print('# running:', mn_cmd)
for c in mn_cmd:
    subprocess.Popen(
        c.split(' ')).communicate()

print('# ftab updates')
for f in tb_cmd:
    print(f)

