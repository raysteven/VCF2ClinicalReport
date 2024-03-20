#DEFINE PATHS
working_path="/path/to/workdir"
## Specify the reference genome
reference_genome_path="/path/to/Homo_sapiens_assembly38.fasta"


NUM_THREADS=32


genotypeGVCFs_output="$working_path/output_genotypeGVCFs"


##############
### SplitVcfs

SplitVcfs_output_SNP="$working_path/output_SplitVcfs_SNP"
SplitVcfs_output_Indels="$working_path/output_SplitVcfs_Indels"

mkdir -p $SplitVcfs_output_SNP
mkdir -p $SplitVcfs_output_Indels


for GVCF_FILE in "$genotypeGVCFs_output/"*.vcf.gz; do
    echo $GVCF_FILE
    BASE_NAME=$(basename "$GVCF_FILE" .vcf.gz)

    SNP_OUTPUT="$SplitVcfs_output_SNP/${BASE_NAME}_snp.vcf"
    INDEL_OUTPUT="$SplitVcfs_output_Indels/${BASE_NAME}_indel.vcf"

    gatk SplitVcfs \
    -I $GVCF_FILE \
    -SNP_OUTPUT $SNP_OUTPUT \
    -INDEL_OUTPUT $INDEL_OUTPUT \
    -STRICT false 2>&1 | tee $SplitVcfs_output_SNP/SplitVcfs.txt $SplitVcfs_output_Indels/SplitVcfs.txt
done


##############
### SelectVariants

SelectVariants_output_SNP="$working_path/output_SelectVariants_SNP"
SelectVariants_output_Indels="$working_path/output_SelectVariants_Indels"

mkdir -p $SelectVariants_output_SNP
mkdir -p $SelectVariants_output_Indels

for GVCF_FILE in "$SplitVcfs_output_SNP/"*.vcf; do
    #echo $GVCF_FILE
    BASE_NAME=$(basename "$GVCF_FILE" .vcf)

    SV_output_SNP="$SelectVariants_output_SNP/${BASE_NAME}.vcf"

    gatk SelectVariants \
    -R $reference_genome_path \
    -V $GVCF_FILE \
    --select-type-to-include SNP \
    -O $SV_output_SNP >> $SelectVariants_output_SNP/SelectVariants_SNP.txt 2>&1

done

for GVCF_FILE in "$SplitVcfs_output_Indels/"*.vcf; do
    #echo $GVCF_FILE
    BASE_NAME=$(basename "$GVCF_FILE" .vcf)

    SV_output_Indels="$SelectVariants_output_Indels/${BASE_NAME}.vcf"

    gatk SelectVariants \
    -R $reference_genome_path \
    -V $GVCF_FILE \
    --select-type-to-include INDEL \
    -O $SV_output_Indels >> $SelectVariants_output_Indels/SelectVariants_Indels.txt 2>&1

done


##############
### VariantFiltration

VariantFiltration_output_SNP="$working_path/output_VariantFiltration_SNP"
VariantFiltration_output_Indels="$working_path/output_VariantFiltration_Indels"

mkdir -p $VariantFiltration_output_SNP
mkdir -p $VariantFiltration_output_Indels

for GVCF_FILE in "$SelectVariants_output_SNP/"*.vcf; do
    #echo $GVCF_FILE
    BASE_NAME=$(basename "$GVCF_FILE" .vcf)

    VF_output_SNP="$VariantFiltration_output_SNP/${BASE_NAME}_filtered.vcf"

    gatk VariantFiltration \
    -V $GVCF_FILE \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "FS > 200.0" --filter-name "FS200" \
    -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O $VF_output_SNP >> $VariantFiltration_output_SNP/VariantFiltration_SNP.txt 2>&1

done

for GVCF_FILE in "$SelectVariants_output_Indels/"*.vcf; do
    #echo $GVCF_FILE
    BASE_NAME=$(basename "$GVCF_FILE" .vcf)

    VF_output_Indels="$VariantFiltration_output_Indels/${BASE_NAME}_filtered.vcf"

    gatk VariantFiltration \
    -V $GVCF_FILE \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "FS > 200.0" --filter-name "FS200" \
    -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O $VF_output_Indels >> $VariantFiltration_output_Indels/VariantFiltration_Indels.txt 2>&1

done


##############
### MergeVariant

MergeVariant_output="$working_path/output_MergeVariant"

mkdir -p $MergeVariant_output

for GVCF_FILE in "$VariantFiltration_output_SNP/"*.vcf; do

    BASE_NAME=$(basename "$GVCF_FILE" _snp_filtered.vcf)
       
    SNP_VCF="$VariantFiltration_output_SNP/${BASE_NAME}_snp_filtered.vcf"
    INDEL_VCF="$VariantFiltration_output_Indels/${BASE_NAME}_indel_filtered.vcf"
    MERGED_VCF="$MergeVariant_output/${BASE_NAME}_filtered_merged.vcf"


    gatk MergeVcfs -I $SNP_VCF -I $INDEL_VCF -O $MERGED_VCF >> $MergeVariant_output/MergeVariant.txt 2>&1


done


##############
### Funcotator
funcotator_source="/path/to/funcotator_dataSources.v1.7.20200521g"

Funcotator_output="$working_path/output_Funcotator"

mkdir -p $Funcotator_output

for GVCF_FILE in "$MergeVariant_output/"*.vcf; do

    BASE_NAME=$(basename "$GVCF_FILE" .vcf)
    ANOTATED_VCF="$Funcotator_output/${BASE_NAME}_annotated.vcf"

    gatk Funcotator \
    -R $reference_genome_path \
    -V $GVCF_FILE \
    -O $ANOTATED_VCF \
    -output-file-format VCF \
    --data-sources-path $funcotator_source \
    --ref-version hg38 >> $Funcotator_output/FuncotatorLog.txt 2>&1

done