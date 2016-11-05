
#Background
    WES stands for whole-exome sequencing which is gaining popularity in the human genetics community due to the moderato costs,manageable data amounts and straightforward interpretation of analysis results.
    So far, there are more than 300 open source softwares for WES data analysis supporting five distinct analytic steps:
* quality control
* alignment
* variant identification
* variant annotation
* visualization


    This pipeline will focus on the first 3 steps, which is QC(fastqc),alignment(bwa,samtools,picard),snp-calling(GATK,bcftools,varscan.jar,freebayes)

#pipeline
    all of the softwares used by this pipeline are located in /home/jmzeng/bio-soft
## quality assessment
    I use the FASTQC for the implementation of QC about the raw data.
    you can search the FASTQC to get more information.
```shell
#/zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first
for id in `find  /zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome/first -name "*.fq.gz"`;
do
bsub -n 4 -q cpu -e err_%J -o out_%J "/zzh_gpfs/apps/FastQC/fastqc $id -o /zzh_gpfs02/jixing/NTL/20161104_Exome/fastQC/" ;
done;
```
## aligment
    you still need to adjust some parameters in below scripts,such as how many thread do you want to use, or the momery ?
###1. Align the paired reads to reference genome using bwa mem.
```shell
   work_dir=/zzh_gpfs02/jixing/NTL/20161104_Exome/snp-calling
   REFERENCE=/zzh_gpfs02/jixing/Annotation/hg19/genome.fa
   BWA=/zzh_gpfs/apps/Bwa/bwa
   DATA=/zzh_gpfs02/jixing/DataBase/bingli_dingyanqing/Exome
   
   for SAMPLE_ID in  193-LB 193-NB 193-TB 1-LB 1-NB 1-TB 215-LB 215-NB 215-TB 40A-LB 40A-NB 40A-TB 4-LB 4-NB 4-TB 5-LB 5-NB 5-TB
   do
   bsub -n 8 -q cpu -e err.bwa_%J -o out.bwa_%J \
   "$BWA mem -M -t 8 $REFERENCE ${DATA}/first/${SAMPLE_ID}_1.clean.fq.gz ${DATA}/first/${SAMPLE_ID}_2.clean.fq.gz > ${work_dir}/${SAMPLE_ID}.sam";
   done

```
    you need to create a config files for this script, just like below:
    sample1  read1.fq.gz read2.fq.gz
    then you just run the script using that config files
###2.change the sam format alignment files to bam format, and sort it in the meantiime
```shell
    work_dir=/home/jmzeng/snp-calling
    reference=/home/jmzeng/ref-database/hg19.fasta   
    bwa_dir=$work_dir/resources/apps/bwa-0.7.11
    picard_dir=$work_dir/resources/apps/picard-tools-1.119
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
```
    you don't need to create a confige files, just run the script in the directory which stores the sam files.
###3.remove the PCR duplicated reads.
```shell
    work_dir=/home/jmzeng/snp-calling
    reference=/home/jmzeng/ref-database/hg19.fasta   
    bwa_dir=$work_dir/resources/apps/bwa-0.7.11
    picard_dir=$work_dir/resources/apps/picard-tools-1.119
    for i in *.sorted.bam
    do
    echo $i
    nohup java  -Xmx60g  -jar $picard_dir/MarkDuplicates.jar \
    CREATE_INDEX=true REMOVE_DUPLICATES=True \
    ASSUME_SORTED=True VALIDATION_STRINGENCY=LENIENT  \
    I=$i OUTPUT=${i%%.*}.dedup.bam METRICS_FILE=tmp.metrics 1>>${i%%.*}.MarkDuplicates.log 2>&1 &
done 
```
    you don't need to create a confige files, just run the script in the directory which stores the bam files.
###4.use GATC to adjust the alignment information (optional)
```shell
    work_dir=/home/jmzeng/snp-calling
    reference=/home/jmzeng/ref-database/hg19.fasta   
    bwa_dir=$work_dir/resources/apps/bwa-0.7.11
    picard_dir=$work_dir/resources/apps/picard-tools-1.119
    gatk=$work_dir/resources/apps/gatk/GenomeAnalysisTK.jar
    for i in *.dedup.bam
    do
    echo $i
    nohup java -Xmx60g -jar $gatk \
    -R $reference \
    -T RealignerTargetCreator \
    -I $i -o ${i%%.*}.intervals \
    -known /home/ldzeng/EXON/ref/1000G_phase1.indels.hg19.sites.vcf 1>>${i%%.*}.RealignerTargetCreator.log 2>&1 &
    done 
```
###5.use GATC to adjust the alignment information (optional)
```shell
    work_dir=/home/jmzeng/snp-calling
    reference=/home/jmzeng/ref-database/hg19.fasta   
    bwa_dir=$work_dir/resources/apps/bwa-0.7.11
    picard_dir=$work_dir/resources/apps/picard-tools-1.119
    gatk=$work_dir/resources/apps/gatk/GenomeAnalysisTK.jar
    for i in *.dedup.bam
    do
    echo $i
    nohup java -Xmx60g -jar $gatk \
    -R $reference -T IndelRealigner \
    -I $i \
    -targetIntervals ${i%%.*}.intervals -o ${i%%.*}.realgn.bam  1>>${i%%.*}.IndelRealigner.log 2>&1 &
    done 
```
###6. use samtools to change the bam files to mpileup format files
```shell
    #6.bam2mpipeup.sh
    reference=/home/jmzeng/ref-database/hg19.fasta  
    for i in *.realgn.bam
    do
    echo $i
    nohup samtools mpileup -f $reference $i 1>${i%%.*}.mpileup.txt 2>${i%%.*}.mpileup.log & 
    done

```
###7.call out the variants by bcftools(a part of samtools) according  to the bam files.
    
```shell
    #7.snp-calling by bcftools
    reference=/home/jmzeng/ref-database/hg19.fasta  
    for i in *.realgn.bam
    do
    echo $i
    samtools mpileup -guSDf  $reference  $i | bcftools view -cvNg - > ${i%%.*}.bcftools.vcf
    done 

```
###8.optional(depends on the experiment, if you sequence one sample by multiple lanes)
```shell
    #8.Merge individual BAM files
    samtools merge sampe.merged.bam  *.realgn.bam
    samtools index sampe.merged.bam
```
###9.call out the variants by freebayes according  to the bam files.
```shell
    #9.snp-calling by freebayes
    reference=/home/jmzeng/ref-database/hg19.fasta
    for i in *.realgn.bam
    do
    echo $i 
    nohup /home/jmzeng//bio-soft/freebayes/bin/freebayes -f $reference $i 1>${i%%.*}.freebayes.vcf 2>${i%%.*}.freebayes.log &  
    done 

```
###10.call out the variants by GATK according  to the bam files.
```shell
    #10. Call SNPs using Unified Genotyper
    work_dir=/home/jmzeng/snp-calling
    reference=/home/jmzeng/ref-database/hg19.fasta   
    bwa_dir=$work_dir/resources/apps/bwa-0.7.11
    picard_dir=$work_dir/resources/apps/picard-tools-1.119
    gatk=$work_dir/resources/apps/gatk/GenomeAnalysisTK.jar
    for i in *.realgn.bam
    do
    echo $i 
    java -Xmx60g -jar $gatk \
    -T UnifiedGenotyper -R $reference \
    -I $i -o ${i%%.*}.gatk.UG.vcf \
       -stand_call_conf 30.0 \
       -stand_emit_conf 0 \
       -glm BOTH \
       -rf BadCigar 
    done 

```
###11.call out the variants by varscan according  to the mpileup files.
```shell
    #11.snp-calling by varscan
    for i in *.mpileup.txt
    do
    echo $i
    java -jar  /home/jmzeng/bio-soft/VarScan.v2.3.8.jar  mpileup2snp   $i  --output-vcf 1  \
    1>${i%%.*}.varscan.snp.vcf   2>${i%%.*}.varscan.snp.log 
    java -jar  /home/jmzeng/bio-soft/VarScan.v2.3.8.jar  mpileup2indel $i  --output-vcf 1  \
    1>${i%%.*}.varscan.Indel.vcf 2>${i%%.*}.varscan.Indel.vcf 
    done 

```
###12. hold on 
```shell
    hold on 
```
