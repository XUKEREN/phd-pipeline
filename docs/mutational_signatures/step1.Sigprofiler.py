from SigProfilerExtractor import sigpro as sig

sig.sigProfilerExtractor('vcf', 'results', 'teeth_25_vcf', reference_genome="GRCh38", opportunity_genome = "GRCh38", context_type = "default", exome = False, minimum_signatures=1, maximum_signatures=10, nmf_replicates=100, resample = True, batch_size=1, cpu=-1, gpu=False,nmf_init="random", precision= "single", matrix_normalization= "gmm", min_nmf_iterations= 10000, max_nmf_iterations=1000000, nmf_test_conv= 10000, nmf_tolerance= 1e-15,nnls_add_penalty=0.05, nnls_remove_penalty=0.01, initial_remove_penalty=0.05, de_novo_fit_penalty=0.02,get_all_signature_matrices= False)

# decompose other signature solutions
# five signatures
from SigProfilerExtractor import decomposition as decomp
signatures = "/dir/results/SBS96/All_Solutions/SBS96_5_Signatures/Signatures/SBS96_S5_Signatures.txt"
activities="/dir/results/SBS96/All_Solutions/SBS96_5_Signatures/Activities/SBS96_S5_NMF_Activities.txt"
samples="/dir/BCFtools.filter.tumoronly.autosomal.vcf/results/SBS96/Samples.txt"
output="/dir/BCFtools.filter.tumoronly.autosomal.vcf/results/SBS96/output_5sig"

decomp.decompose(signatures, activities, samples,  output, signature_database=None, nnls_add_penalty=0.05, nnls_remove_penalty=0.01, initial_remove_penalty=0.05, de_novo_fit_penalty=0.02, genome_build="GRCh38", refit_denovo_signatures=True, make_decomposition_plots=True, connected_sigs=True, verbose=False)

# six signatures
from SigProfilerExtractor import decomposition as decomp
signatures = "/dir/results/SBS96/All_Solutions/SBS96_6_Signatures/Signatures/SBS96_S6_Signatures.txt"
activities="/dir/results/SBS96/All_Solutions/SBS96_6_Signatures/Activities/SBS96_S6_NMF_Activities.txt"
samples="/dir/results/SBS96/Samples.txt"
output="/dir/results/SBS96/output_6sig"

decomp.decompose(signatures, activities, samples,  output, signature_database=None, nnls_add_penalty=0.05, nnls_remove_penalty=0.01, initial_remove_penalty=0.05, de_novo_fit_penalty=0.02, genome_build="GRCh38", refit_denovo_signatures=True, make_decomposition_plots=True, connected_sigs=True, verbose=False)


# other context types
from SigProfilerExtractor import sigpro as sig
seeds="/dir/results/Seeds.txt"

sig.sigProfilerExtractor('vcf', 'SBS288', 'teeth_25_vcf',reference_genome="GRCh38", opportunity_genome = "GRCh38", context_type = "SBS288", exome = False, minimum_signatures=1, maximum_signatures=10, nmf_replicates=100, resample = True, batch_size=1, cpu=-1, gpu=False,nmf_init="random", precision= "single", matrix_normalization= "gmm", min_nmf_iterations= 10000, max_nmf_iterations=1000000, nmf_test_conv= 10000, nmf_tolerance= 1e-15,nnls_add_penalty=0.05, nnls_remove_penalty=0.01, initial_remove_penalty=0.05, de_novo_fit_penalty=0.02,get_all_signature_matrices= False)


sig.sigProfilerExtractor('vcf', 'SBS1536', 'teeth_25_vcf',reference_genome="GRCh38", opportunity_genome = "GRCh38", context_type = "SBS1536", exome = False, minimum_signatures=1, maximum_signatures=10, nmf_replicates=100, resample = True, batch_size=1, cpu=-1, gpu=False,nmf_init="random", precision= "single", matrix_normalization= "gmm", min_nmf_iterations= 10000, max_nmf_iterations=1000000, nmf_test_conv= 10000, nmf_tolerance= 1e-15,nnls_add_penalty=0.05, nnls_remove_penalty=0.01, initial_remove_penalty=0.05, de_novo_fit_penalty=0.02,get_all_signature_matrices= False)

# decompose other signature solutions
# 3 signatures
from SigProfilerExtractor import decomposition as decomp
signatures = "/dir/SBS1536/SBS1536/All_Solutions/SBS1536_3_Signatures/Signatures/SBS1536_S3_Signatures.txt"
activities="/dir/SBS1536/SBS1536/All_Solutions/SBS1536_3_Signatures/Activities/SBS1536_S3_NMF_Activities.txt"
samples="/dir/SBS1536/SBS1536/Samples.txt"
output="/dir/SBS1536/SBS1536/output_3sig"

decomp.decompose(signatures, activities, samples,  output, signature_database=None, nnls_add_penalty=0.05, nnls_remove_penalty=0.01, initial_remove_penalty=0.05, de_novo_fit_penalty=0.02, genome_build="GRCh38", refit_denovo_signatures=True, make_decomposition_plots=True, connected_sigs=True, verbose=False)

# 4 signatures
from SigProfilerExtractor import decomposition as decomp
signatures = "/dir/SBS1536/SBS1536/All_Solutions/SBS1536_4_Signatures/Signatures/SBS1536_S4_Signatures.txt"
activities="/dir/SBS1536/SBS1536/All_Solutions/SBS1536_4_Signatures/Activities/SBS1536_S4_NMF_Activities.txt"
samples="/dir/SBS1536/SBS1536/Samples.txt"
output="/dir/SBS1536/SBS1536/output_4sig"

decomp.decompose(signatures, activities, samples,  output, signature_database=None, nnls_add_penalty=0.05, nnls_remove_penalty=0.01, initial_remove_penalty=0.05, de_novo_fit_penalty=0.02, genome_build="GRCh38", refit_denovo_signatures=True, make_decomposition_plots=True, connected_sigs=True, verbose=False)

