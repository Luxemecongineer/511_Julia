
cwd_path = "C:\\working\\cs\\Econometrics\\511_Julia\\Julia_intro\\SingleAgentModels\\ShortestPath"
file_name = "graph.txt"
infile=joinpath(cwd_path,file_name)


function read_graph(in_file)
    graph = Dict()
    infile = open(in_file, "r")
    for line in readlines(infile)
        elements = reverse!(split(line, ','))
        node = strip(pop!(elements))
        graph[node] = []
        if node != "node99"
            for element in elements
                dest, cost = split(element)
                push!(graph[node], [strip(dest), float(cost)])
            end
        end

    end
    close(infile)
    return graph
end


function update_J(J, graph)
    next_J = Dict()
    for node in keys(graph)
        if node == "node99"
            next_J[node] = 0
        else
            next_J[node] = minimum([cost + J[dest] for (dest, cost) in graph[node]])
        end
    end
    return next_J
end


function print_best_path(J, graph)
    sum_costs = 0
    current_location = "node0"
    while current_location != "node99"
        println(current_location)
        running_min = 1e10
        minimizer_dest = "none"
        minimizer_cost = 1e10
        for (dest, cost) in graph[current_location]
            cost_of_path = cost + J[dest]
            if cost_of_path < running_min
                running_min = cost_of_path
                minimizer_cost = cost
                minimizer_dest = dest
            end
        end

        current_location = minimizer_dest
        sum_costs += minimizer_cost
    end

    println("node99")
    @printf "\nCost: %.2f" sum_costs
end

graph = read_graph(infile)
M = 1e10
J = Dict()
for node in keys(graph)
    J[node] = M
end
J["node99"] = 0

while true
    next_J = update_J(J, graph)
    if next_J == J
        break
    else
        J = next_J
    end
end

print_best_path(J, graph)
