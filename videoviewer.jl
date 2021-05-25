### A Pluto.jl notebook ###
# v0.14.5

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
end

# ╔═╡ a1cfd32a-193a-43b8-9745-bb0161ac3f4c
@bind replay Button("Replay Videos")

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

# ╔═╡ e3ee9c93-95ba-48a0-8d22-72694ae193ed
begin
	runs = CSV.File("reconstruction_indexes.csv", header=0) |> DataFrame
	subjs, tasks = Tables.columntable(runs)
	md"""
	### Open me to see CSV file pulling
	"""
end

# ╔═╡ fd3abaa8-7dbd-49b6-a5cf-e5e61bf79ebb
@bind subj Select(subjs)

# ╔═╡ dd772e4d-903b-49a7-b4a4-e3fda4591178
@bind task Select(tasks[findall(x -> x == subj, subjs)])

# ╔═╡ 826fcef9-1c2a-4ecd-adad-55ad68d612c8
begin	
	run(`rsync hermia:/scratch/pkumar/sr-resolution/train/"$subj"/2drt/recon/"$subj"_"$task"_recon.h5 ./reconstruction.h5`)

	run(`rsync hermia:/server/sdata_new/Speech/dataset/"$subj"/2drt/recon/"$subj"_"$task"_recon.h5 ./original.h5`)

	original = h5open("original.h5", "r") do file
		read(file, "recon")
	end

	reconstruction = h5open("reconstruction.h5", "r") do file
		read(file, "recon");
	end
	
	original_matrix = convert_to_matrix(original, true, false)
	reconstruction_matrix = convert_to_matrix(reconstruction, false, true)
	
	save_video(original_matrix, "original.mp4")
	save_video(reconstruction_matrix, "reconstruction.mp4")
	
	var_to_update = 1

	md"""
	### Open me to see data pulling
	"""
end

# ╔═╡ fad8173d-50e9-4101-ad89-8f7172ac7e9c
md"""
Frame: $(@bind frame Slider(1:size(reconstruction,3), show_value=true))
Frame Text: $(@bind frame NumberField(1:size(reconstruction,3)))
"""

# ╔═╡ e98b5534-6f33-4563-b553-d6d47e171c35
md"""
### Speech Dataset Recon
$(heatmap(reverse(original[:,:,frame], dims=1), c=:grays, size=(350,350), legend=:none))
### Spiral / Off Resonance Correction Reconstruction
$(heatmap(reconstruction[:,:,frame]', c=:grays, size=(350,350), legend=:none))
"""

# ╔═╡ 3369f6f7-490d-4f69-b732-f7f97a3cfeef
frame * 6.004 * 2 / 1000

# ╔═╡ f73816c1-98eb-418c-903d-582a43939996
begin
	print(var_to_update) #little hack to make it update post video recon.
	print(replay) #little hack to make it update post video recon.
	
	md"""
	### Speech Dataset Recon
	$((LocalResource("original.mp4", :width => 333, :height => 333, :autoplay => true)))
	### Spiral / Off Resonance Correction Reconstruction
	$(LocalResource("reconstruction.mp4", :width => 333, :height => 333, :autoplay => true))
	"""
end

# ╔═╡ Cell order:
# ╟─fd3abaa8-7dbd-49b6-a5cf-e5e61bf79ebb
# ╟─dd772e4d-903b-49a7-b4a4-e3fda4591178
# ╟─e98b5534-6f33-4563-b553-d6d47e171c35
# ╟─fad8173d-50e9-4101-ad89-8f7172ac7e9c
# ╟─3369f6f7-490d-4f69-b732-f7f97a3cfeef
# ╟─f73816c1-98eb-418c-903d-582a43939996
# ╟─a1cfd32a-193a-43b8-9745-bb0161ac3f4c
# ╟─826fcef9-1c2a-4ecd-adad-55ad68d612c8
# ╟─b398358b-3429-45d3-a4f0-204867153a9b
# ╟─27503d66-4288-4dc2-ba18-5a00598560e1
# ╟─e3ee9c93-95ba-48a0-8d22-72694ae193ed
# ╟─a0c4995d-a6f9-471b-8bd6-39bcc4f8bfdf
