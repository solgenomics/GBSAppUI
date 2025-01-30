#!/bin/bash
cp /gbsappui/slurm.conf  /etc/slurm/
cp /gbsappui/cgroup.conf  /etc/slurm/
sed -i s/localhost/$HOSTNAME/g /etc/slurm/slurm.conf
cp /gbsappui/config.sh  /GBSapp/examples/proj/
chown munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key
RUN conda config --add channels conda-forge
RUN conda config --add channels defaults
RUN conda config --add channels r
RUN conda config --add channels bioconda

#Install ngm
RUN conda install nextgenmap -y
/etc/init.d/munge start
/etc/init.d/slurmctld start
/etc/init.d/slurmd start
/etc/init.d/postfix start
touch /var/log/gbsappui/error.log
#chmod 777 /var/log/gbsappui/error.log
sleep 5
/gbsappui/script/gbsappui_server.pl -r -p 8090 2> /var/log/gbsappui/error.log
tail -f /var/log/gbsappui/error.log
