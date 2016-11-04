#!/bin/bash
##### project ####
#BSUB -J zhiyi_yeyaping
#BSUB -n 4
#BSUB -o output_%J
#BSUB -e errput_%J
#BSUB -q cpu

for SAMPLE_ID in  305_LB 305_NB 305_TB 317_LB 317_NB 317_TB 326_LB 326_NB 326_TB 335_LB 335_NB 335_TB 352_LB 352_NB 352_TB P574972_LB P574972_NB P574972_TB
do
cat > ${SAMPLE_ID}.sh <<EOF
#!/bin/bash
##### project ####
#BSUB -J zhiyi_yeyaping_20160704
#BSUB -n 8
#BSUB -R "span[ptile=4]"
#BSUB -o output_%J
#BSUB -e errput_%J
#BSUB -q cpu

mkdir /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/second/${SAMPLE_ID}
cd /zzh_gpfs/data/sunjing/2016-05-06-tumor/result/${SAMPLE_ID}/clean_data
cp *.clean.fq.gz /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/second/${SAMPLE_ID}/
cd -
EOF
bsub < ${SAMPLE_ID}.sh
rm ${SAMPLE_ID}.sh
done
#=========================================================================================
