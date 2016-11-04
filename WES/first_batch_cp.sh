#!/bin/bash
##### project ####
#BSUB -J zhiyi_yeyaping
#BSUB -n 4
#BSUB -o output_%J
#BSUB -e errput_%J
#BSUB -q cpu

for SAMPLE_ID in  193-LB 193-NB 193-TB 1-LB 1-NB 1-TB 215-LB 215-NB 215-TB 40A-LB 40A-NB 40A-TB 4-LB 4-NB 4-TB 5-LB 5-NB 5-TB
do
cat > ${SAMPLE_ID}.sh <<EOF
#!/bin/bash
##### project ####
#BSUB -J zhiyi_yeyaping_20160704
#BSUB -n 4
#BSUB -R "span[ptile=4]"
#BSUB -o output_%J
#BSUB -e errput_%J
#BSUB -q cpu

mkdir /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first/${SAMPLE_ID}
cd /zzh_gpfs/data/sunjing/2016-05-06-tumor/result_cleandata_and_alignment/${SAMPLE_ID}/clean_data
cp *_1.clean.fq.gz /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first/${SAMPLE_ID}_1.clean.fq.gz
cp *_2.clean.fq.gz /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first/${SAMPLE_ID}_2.clean.fq.gz
cd -
EOF
bsub < ${SAMPLE_ID}.sh
rm ${SAMPLE_ID}.sh
done
#=========================================================================================

