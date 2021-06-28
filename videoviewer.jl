### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ a0c4995d-a6f9-471b-8bd6-39bcc4f8bfdf
begin
	using CSV
	using PlutoUI
	using DataFrames
	using HDF5
	using Images
	using ImageMagick
	using Plots
	import VideoIO
	using JSON
	using DataStructures
	using StatsBase
	using ColorSchemes
end

# ╔═╡ a6c8c986-3878-49e2-b408-962a6349b6be
md"""
## Coil Sensitivity Maps
"""

# ╔═╡ 1f553f54-fa19-40f8-a358-29bf9028e36e
begin
	stringdata = join(readlines("metafile_public_20210129.json"))
	dict = JSON.parse(stringdata, dicttype=DataStructures.OrderedDict)
	subjs = Vector{String}()
	tasks = Vector{String}()
	
	for item in dict
		task = [item[2]["task"][x]["prefix"][8:end] for x = 1:size(item[2]["task"],1)]
		subj = [item[1] for i = 1:size(task, 1)]
		
		
		
		append!(tasks, task)
		append!(subjs, subj)
	end
	
	md"""
	### Open me to see JSON parsing
	"""
end

# ╔═╡ fd3abaa8-7dbd-49b6-a5cf-e5e61bf79ebb
@bind subj Select(unique(subjs))

# ╔═╡ dd772e4d-903b-49a7-b4a4-e3fda4591178
@bind task Select(tasks[findall(x -> x == subj, subjs)])

# ╔═╡ b398358b-3429-45d3-a4f0-204867153a9b
function convert_to_matrix(inputx, flip, transpose)
	
	inputx = inputx ./ maximum(inputx, dims=1:2) * 255
	
	output = Array{Array{UInt8, 2}, 1}(undef, size(inputx,3))
	for idx = 1:size(inputx,3)
		if flip
			output[idx] = reverse(floor.(inputx[:,:,idx]), dims=1)
		else
			output[idx] = floor.(inputx[:,:,idx])
		end
		
		if transpose
			output[idx] = output[idx]'
		end
		
		output[idx] = reverse(output[idx], dims=1)
	end
	
	return output
end

# ╔═╡ 27503d66-4288-4dc2-ba18-5a00598560e1
function save_video(input, filename)
	encoder_options = (crf=0, color_range=2, preset="medium")
	VideoIO.save(filename, input, framerate=83, encoder_options=encoder_options)
end

# ╔═╡ 826fcef9-1c2a-4ecd-adad-55ad68d612c8
begin
	loaded = 0
	run(`rsync hermia:/scratch/pkumar/sr-resolution/train/"$subj"/2drt/recon/"$subj"_"$task"_recon.h5 ./reconstruction.h5`)

	run(`rsync hermia:/server/sdata_new/Speech/dataset/"$subj"/2drt/recon/"$subj"_"$task"_recon.h5 ./original.h5`)

	
	original = h5open("original.h5", "r") do file
		read(file, "recon")
	end

	reconstructionReal = h5open("reconstruction.h5", "r") do file
		read(file, "recon_Re");
	end
	
	reconstructionImag = h5open("reconstruction.h5", "r") do file
		read(file, "recon_Im");
	end
	
	sensmapReal = h5open("reconstruction.h5", "r") do file
		read(file, "sens_map_Re");
	end
	
	sensmapImag = h5open("reconstruction.h5", "r") do file
		read(file, "sens_map_Im");
	end
	
	
	fieldmap = h5open("reconstruction.h5", "r") do file
		read(file, "offres_map")
	end
	
	
	
	
	reconstruction = abs.(reconstructionReal .+ (reconstructionImag)im)
	sensmap = (sensmapReal .+ (sensmapImag)im)
	magdiff = abs.(original - reconstruction)	
	viz = cat(original, reconstruction, magdiff, dims=2)
	viz_matrix = convert_to_matrix(viz, true, false)
	
	
	
	save_video(viz_matrix, "viz.mp4")

	loaded = 1
	
	md"""
	### Open me to see data pulling
	"""
end

# ╔═╡ f73816c1-98eb-418c-903d-582a43939996
begin
	print(loaded) #little hack to make it update post video recon.
	
	md"""
	#### Speech Open Dataset / Off-resonance Correction / |Difference|
	$(LocalResource("viz.mp4", :width=> 999, :height => 333, :autoplay => true, :loop => true))
	"""
end

# ╔═╡ fad8173d-50e9-4101-ad89-8f7172ac7e9c
md"""
Frame: $(@bind frame Slider(1:size(reconstruction,3), show_value=true))
Frame Text: $(@bind frame NumberField(1:size(reconstruction,3)))
"""

# ╔═╡ e98b5534-6f33-4563-b553-d6d47e171c35
md"""
#### ----Original Speech Recon --------------- New Recon ----------

$(heatmap(reverse(original[:,:,frame],dims=1), c=:grays, size=(300,300)))
$(heatmap(reverse(reconstruction[:,:,frame], dims=1), c=:grays, size=(300,300)))

#### ---------|Original - New| ---------------- Off-Res. Field Map ------

$(heatmap(reverse(magdiff[:,:,frame], dims=1), c=:grays, size=(300,300)))
$(heatmap(fieldmap[:,:,frame]', size=(300,300)))
"""

# ╔═╡ 3369f6f7-490d-4f69-b732-f7f97a3cfeef
frame * 6.004 * 2 / 1000

# ╔═╡ 1fbf5675-b735-4773-98cd-0bd50ec6e55c
heatmap(reshape(abs.(sensmap[:,:,1,1:4]), 106, 106*4), c=:grays, size=(1000,200))

# ╔═╡ 84f8699b-80aa-45d4-9d46-2085e63df629
heatmap(reshape(abs.(sensmap[:,:,1,5:8]), 106, 106*4), c=:grays, size=(1000,200))

# ╔═╡ Cell order:
# ╟─fd3abaa8-7dbd-49b6-a5cf-e5e61bf79ebb
# ╟─dd772e4d-903b-49a7-b4a4-e3fda4591178
# ╠═826fcef9-1c2a-4ecd-adad-55ad68d612c8
# ╠═f73816c1-98eb-418c-903d-582a43939996
# ╟─e98b5534-6f33-4563-b553-d6d47e171c35
# ╟─fad8173d-50e9-4101-ad89-8f7172ac7e9c
# ╟─3369f6f7-490d-4f69-b732-f7f97a3cfeef
# ╟─a6c8c986-3878-49e2-b408-962a6349b6be
# ╟─1fbf5675-b735-4773-98cd-0bd50ec6e55c
# ╠═84f8699b-80aa-45d4-9d46-2085e63df629
# ╟─1f553f54-fa19-40f8-a358-29bf9028e36e
# ╟─b398358b-3429-45d3-a4f0-204867153a9b
# ╟─27503d66-4288-4dc2-ba18-5a00598560e1
# ╟─a0c4995d-a6f9-471b-8bd6-39bcc4f8bfdf
