# Sen Lu
# Feb 10th

#########################
#     graph function    #
#########################
#--- read data then create the graph of the physical structure.
# Notice that this funciton use dict to store value
# the upside of using Dict is indexing by string. valid for limited # of discrete state space
function read_graph(in_file)
    # create the object that one could store value to return
    graph = Dict()
    # obtain the name, then import from cwd dir
    infile = open(in_file,"r")
    # read data line by line
    for line in readlines(infile)
        elements = reverse!(split(line,','))
        node = strip(pop!(elements))
        graph[node] = []
        if node != "node99"
            for element in elements
                dest, cost = split(element)
                push!(graph[node],[strip(dest), float(cost)])
            end
        end

    end
    close(infile)
    return graph
end

# use join path to create full path!
cwd_path = "C:\\working\\cs\\Econometrics\\511_Julia\\Julia_intro\\SingleAgentModels\\ShortestPath"
file_name = "graph.txt"
infile=joinpath(cwd_path,file_name)

# one could call the function defined above with a path arg.
test_graph = read_graph(infile)


#########################
#    update function    #
#########################
#giving the graph graph and current pseudo optimal cost vector J, following function updates efficient path
function update_J(J,graph)  # J is a vector of optimal cost, graph is the Dict create by data
    # Create an empty dictionary to store and return
    next_J= Dict()
    # keys(graph) query the index of dict, then one could use it to run loop.
    for node in keys(graph)
        if node == "node99"
            next_J[node] = 0
        else
            # minimum( a vector ). the vector is defined in line
            # Following equation is like Bellman equation!
            next_J[node] = minimum([cost + J[dest] for (dest, cost) in graph[node] ])
        end
    end
    return next_J
end


#########################
#  Initial  guess  J_0  #
#########################
# generate the initial guess
# Notice that we set J_0["node99"][1] = 1e10. One could update the value in inner loop.
const M = 1e10
J_0 = Dict()
for node in keys(test_graph)
    J_0[node] = M
end

# J_0["node99"] = 0
test_graph["node99"]

# TEST for oneshot updating
J_1 = update_J(J_0,test_graph)


@printf "\n cost is %.2f" J_1["node87"][1]

#--- Test
cwd_path = "C:\\working\\cs\\Econometrics\\511_Julia\\Julia_intro\\SingleAgentModels\\ShortestPath"
file_name = "graph.txt"
in_file=joinpath(cwd_path,file_name)
infile = open(in_file,"r")

A = Array{Real}(100,100)

tmp_x = readlines(infile)
tmp_x[1]
tmp_x[2]

tmp_s = split(tmp_x[1],",")
tmp_s2 = reverse!(tmp_s)
# strip function remove all leading and trailing blanks. pop! return the last element and remove it from original data
node = strip(pop!(tmp_s2))
tmp_s2
node
# if the node is node99, then nothing to do.
if node!="node99"
    for i in 1:length(tmp_s2)
        println(tmp_s2[i])
        dest, cost = split(tmp_s2[i])
        println(dest)
        println(cost)
    end

    # println(tmp_s2)
    # println(tmp_s2[1])
    # println(tmp_s2[2])
    # println(tmp_s2[3])
end
