using NetworkInference
using Base.Test

# Only run tests if the EmpiricalBayes package exists
if EB_EXISTS

using EmpiricalBayes

println("testing empirical bayes glue functions...")

data_folder_path = joinpath(dirname(@__FILE__), "data")

# Test to_index functions
@test to_index("bbb", "aaa") == to_index("aaa", "bbb")
@test to_index("aaa", "bbb") == ("bbb", "aaa")

n1 = Node("aaa", [], 0, [])
n2 = Node("bbb", [], 0, [])
@test to_index(n1, n2) == to_index(n2, n1)
@test to_index(n1, n2) == ("bbb", "aaa")

@test to_index([n1, n2]) == to_index([n2, n1])
@test to_index([n1, n2]) == ("bbb", "aaa")


# Test the make_priors function
prior_path = joinpath(data_folder_path, "test_priors.txt")
reference_priors = Dict( [ (("bbb", "aaa"), 1) ,
                     (("ccc", "aaa"), 0) ,
                     (("ccc", "bbb"), 1)
                   ])
@test make_priors(prior_path) == reference_priors



# Test the empirical_bayes function
println("inferring test empirical bayes network...")
mi_benchmark = readdlm(joinpath(data_folder_path, "mi.txt"))
mi_benchmark = mi_benchmark[1:2:end, :] # skip repeated edges

mi_priors_filepath = joinpath(data_folder_path, "mi_priors.txt")
mi_priors = readdlm(mi_priors_filepath)
mi_priors = mi_priors[1:2:end, :] # skip repeated edges
prior_dict = make_priors(mi_priors_filepath)

yeast_test_data = joinpath(data_folder_path, "yeast1_10_data.txt")
nodes = get_nodes(yeast_test_data)
mi_network = InferredNetwork(MINetworkInference(), nodes)

eb_network = empirical_bayes(mi_network, prior_dict, 5)
eb_weights = [e.weight for e in eb_network.edges]

benchmark_stats = convert(Array{Float64}, mi_benchmark[:, 3])
benchmark_priors = convert(Array{Float64}, mi_priors[:, 3])
ref_weights = empirical_bayes(benchmark_stats, benchmark_priors, 5)

@test eb_weights ≈ sort(ref_weights, rev=true) atol=0.0001




println("empirical bayes glue tests passed")
end