work_dir=/zzh_gpfs02/jixing/NTL/20161104_Exome/snp-calling
REFERENCE=/zzh_gpfs02/jixing/Annotation/hg19/genome.fa
BWA=/zzh_gpfs/apps/Bwa/bwa
DATA=/zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome

for SAMPLE_ID in  193-LB 193-NB 193-TB 1-LB 1-NB 1-TB 215-LB 215-NB 215-TB 40A-LB 40A-NB 40A-TB 4-LB 4-NB 4-TB 5-LB 5-NB 5-TB
do
bsub -n 8 -q cpu -e err.bwa_%J -o out.bwa_%J \
"$BWA mem -M -t 8 $REFERENCE ${DATA}/first/${SAMPLE_ID}_1.clean.fq.gz ${DATA}/first/${SAMPLE_ID}_2.clean.fq.gz > ${work_dir}/${SAMPLE_ID}.sam";
done
