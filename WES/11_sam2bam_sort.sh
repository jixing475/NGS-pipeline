work_dir=/zzh_gpfs02/jixing/NTL/20161104_Exome/snp-calling
REFERENCE=/zzh_gpfs02/jixing/Annotation/hg19/genome.fa
BWA=/zzh_gpfs/apps/Bwa/bwa
DATA=/zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome

picard_dir=


for i in *sam
do
echo $i
echo ${i%.*}.sorted.bam
nohup java  -Xmx60g  -jar $picard_dir/AddOrReplaceReadGroups.jar  \
I=$i \
O=${i%.*}.sorted.bam  \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
RGID=${i%.*} \
RGLB="pe" \
RGPU="HiSeq-2000" \
RGSM=${i%.*} \
RGCN="Human Genetics of Infectious Disease" \
RGDS=hg19 \
RGPL=illumina \
VALIDATION_STRINGENCY=SILENT >> ${i%.*}.AddOrReplaceReadGroups.log 2>&1 &
done 
