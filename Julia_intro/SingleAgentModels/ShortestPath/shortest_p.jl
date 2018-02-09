# Sen Lu

function read_graph(in_file)
    # create the object that one could store value to return
    graph = Dict()
    # obtain the name, then import from cwd dir
    infile = open(in_file,"r")
    # read data line by line
    for line in readlines(infile)
        elements = reverse!(split(line,','))
        nothing
    end
    return graph
end

cwd_path = "C:\\working\\cs\\Econometrics\\511_Julia\\Julia_intro\\SingleAgentModels\\ShortestPath"
file_name = "graph.txt"
infile=joinpath(cwd_path,file_name)
read_graph(infile)
