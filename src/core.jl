begin
	using Pkg
	Pkg.activate("..")
	using NIfTI

	
	niftyReg_path = joinpath("../nift_reg_app","bin")
	@assert isdir(niftyReg_path)
	aladin_path = abspath(joinpath(niftyReg_path,"reg_aladin.exe"))
	f3d_path = abspath(joinpath(niftyReg_path,"reg_f3d.exe"));
end;

"""
	This function is a high-level wrapper function that wraps all other functions.
	Call `run_registration(v1::Array{Float32, 3}, v2::Array{Float32, 3}, mask::Array{Bool, 3})`.
	For `mask`, areas that need to get registered are with values = true.
"""
function run_registration(v1::Array{Float32, 3}, v2::Array{Float32, 3}, mask::Array{Bool, 3}; BB_offset = 50, del_tmp_files = false, stationary_acq = "v1")
	# swap v1 or v2 if necessary
	if stationary_acq == "v2"
		temp = deepcopy(v1)
		v1 = deepcopy(v2)
		v2 = temp
	end
	# Check args
	x1, y1, num_slice_v1 = size(v1)
	x2, y2, num_slice_v2 = size(v2)
	x3, y3, num_slice_mask = size(mask)
	@assert num_slice_v1 == num_slice_v2 == num_slice_mask
	@assert x1 == x2 == x3
	@assert y1 == y2 == y3
	# get BB
	BB = find_BB(mask, x1, y1, num_slice_v1, BB_offset)
	# create cropped .nii temp_files
	crop_and_convert2nifty(v1_dicom, v2_dicom, BB)
	# run
	ApplyNiftyReg()
	# get result
	output = postprocess_and_save(BB, x1, y1, num_slice_v1)
	# delete temp files
	if del_tmp_files
		isdir("temp_files") && rm("temp_files")
	end
end


"""
	This function gets bounding box from mask.
"""
function find_BB(mask, x_, y_, l, offset)
	up, down, left, right = nothing, nothing, nothing, nothing
	# top to buttom
	for x = 1 : x_
		up==nothing || break
		for slice_idx = 1 : l
			for y = 1 : y_
				mask[x, y, slice_idx] && (up=x;break)
			end
			up==nothing || break
		end
	end
	# buttom to top
	for x = x_ : -1 : 1
		down==nothing || break
		for slice_idx = 1 : l
			for y = 1 : y_
				mask[x, y, slice_idx] && (down=x;break)
			end
			down==nothing || break
		end
	end
	# left to right
	for y = 1 : y_
		left==nothing || break
		for slice_idx = 1 : l
			for x = 1 : x_
				mask[x, y, slice_idx] && (left=y;break)
			end
			left==nothing || break
		end
	end
	# right to left
	for y = y_ : -1 : 1
		right==nothing || break
		for slice_idx = 1 : l
			for x = 1 : x_
				mask[x, y, slice_idx] && (right=y;break)
			end
			right==nothing || break
		end
	end
	return [max(1, up-offset), min(x_, down+offset), max(1, left-offset), min(y_, right+offset)]
end

"""
	This function crops images based on `BB` and convert to nifty.
"""
function crop_and_convert2nifty(v1_dicom, v2_dicom, BB)
	# created path to save
	isdir("temp_files") || mkdir("temp_files")
	# get BB
	up, down, left, right = BB
	# crop
	v1_dicom_cropped = v1_dicom[up:down, left:right, :]
	v2_dicom_cropped = v2_dicom[up:down, left:right, :]
	# save
	niwrite(joinpath("temp_files", "v1.nii"), NIfTI.NIVolume(v1_dicom_cropped))
	niwrite(joinpath("temp_files", "v2.nii"), NIfTI.NIVolume(v2_dicom_cropped))
end

"""
	This function wraps NiftyReg.
"""
function ApplyNiftyReg()
	temp_path = "temp_files"
	v1_nii_path = abspath(joinpath(temp_path, "with_motion", "v1.nii"))
	v2_nii_path = abspath(joinpath(temp_path, "with_motion", "v2.nii"))
	aff_out_path = abspath(joinpath(temp_path, "aff.txt"))
	aladin_out_path = abspath(joinpath(temp_path, "aladin.nii"))
	cpp_out_path = abspath(joinpath(temp_path, "cpp.nii"))
	f3d_out_path = abspath(joinpath(temp_path, "registered.nii"))
	
	# aladin first
	aladin_command = `$aladin_path -ref "$v1_nii_path" -flo "$v2_nii_path" -aff "$aff_out_path" -res "$aladin_out_path"`
	isfile(aff_out_path) || (run(aladin_command);)
	
	# then f3d
	f3d_command = `$f3d_path -ref "$v1_nii_path" -flo "$v2_nii_path" -aff "$aff_out_path" -res "$f3d_out_path" -cpp "$cpp_out_path"`
	isfile(cpp_out_path) || (run(f3d_command);)
end

# ╔═╡ 581b8144-1857-446a-94a8-8f58031574e1
"""
	This function corrects the orientation of images and save them.
"""
function postprocess_and_save(BB, x, y, l)
	out_path = joinpath("temp_files", "registered.nii")
	rslt = niread(out_path)

	# correct orientation
	up, down, left, right = BB
	output = Array{Float32, 3}(undef, x, y, l)
	output[up:down, left:right, :] = rslt
	return output
end
