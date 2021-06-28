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

# ╔═╡ 826fcef9-1c2a-4ecd-adad-55ad68d612c8
items = readdir("files_for_review")

# ╔═╡ e00aa030-7b04-414c-b6b8-134827b2b6cd
@bind idx NumberField(1:size(items,1)-1)

# ╔═╡ fa9ad729-d9ed-4a6e-ae9a-d5a8630f8995
items[idx+1]

# ╔═╡ 8a0b544f-c2c9-4775-993e-18e90cd761b8
LocalResource("files_for_review/$(items[idx+1])", :width => 2000)

# ╔═╡ Cell order:
# ╟─826fcef9-1c2a-4ecd-adad-55ad68d612c8
# ╟─fa9ad729-d9ed-4a6e-ae9a-d5a8630f8995
# ╟─e00aa030-7b04-414c-b6b8-134827b2b6cd
# ╟─8a0b544f-c2c9-4775-993e-18e90cd761b8
# ╟─a0c4995d-a6f9-471b-8bd6-39bcc4f8bfdf
