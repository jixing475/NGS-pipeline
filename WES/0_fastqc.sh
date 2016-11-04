#/zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first
for id in `find  /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first -name "*.fq.gz"`;
do
bsub -n 4 -q cpu -e err_%J -o out_%J "/zzh_gpfs/apps/FastQC/fastqc $id -o /zzh_gpfs02/jixing/NTL/20161104_Exome/fastQC/" ;
done;
