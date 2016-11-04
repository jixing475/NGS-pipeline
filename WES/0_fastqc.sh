#/zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first
i=1
for id in `find  /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first -name "*.fq.gz"`;
do
echo `date` "start do QC for " $id
bsub -n 4 -q cpu -e err_%J -o out_%J "/zzh_gpfs/apps/FastQC/bin/fastqc $i -o /zzh_gpfs02/jixing/NTL/20161104_Exome/fastQC/" ;
echo `date` "end do QC for " $id
i=$((i+1))
done;
