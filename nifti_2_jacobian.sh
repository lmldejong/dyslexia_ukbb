# Activate modules
unset PYTHONHOME
unset PYTHONPATH
export LD_LIBRARY_PATH=/usr/shared/apps/fsl/6.0.3/lib/:$LD_LIBRARY_PATH
export PATH=usr/shared/apps/fsl/6.0.3/:usr/shared/apps/fsl/6.0.3/bin:$PATH


# Set paths
echo "Setting paths.."
fsl_path=/usr/shared/apps/fsl/6.0.3/bin
ants_path=/home/lucjon/ants/bin/
c3d_path=/home/lucjon//c3d-1.1.0-Linux-x86_64/bin
input_directory=/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas
output_directory=/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/all_subjects
subject_id=3385997

mkdir -p ${output_directory}/${subject_id}


# Define files
echo "Defining input files.."
timepoint_1=${input_directory}/${subject_id}/1st_timepoint/T1.nii.gz
timepoint_2=${input_directory}/${subject_id}/2nd_timepoint/T1.nii.gz 
template=${input_directory}/data/stage_11_syn_template.nii.gz


# Center image:             FSL reorient 2D std
echo "Centering image.."
${fsl_path}/fslreorient2std \
        $timepoint_1 \
        ${output_directory}/${subject_id}/TP1_reor.nii.gz
${fsl_path}/fslreorient2std \
        $timepoint_2 \
        ${output_directory}/${subject_id}/TP2_reor.nii.gz


# ROI selection:            FSL standard_space_roi
echo "Selecting ROI.." 
${fsl_path}/standard_space_roi \
        ${output_directory}/${subject_id}/TP1_reor \
        ${output_directory}/${subject_id}/TP1_reor_ss.nii.gz
${fsl_path}/standard_space_roi \
        ${output_directory}/${subject_id}/TP2_reor \
        ${output_directory}/${subject_id}/TP2_reor_ss.nii.gz


# Brain extraction:         FSL bet
echo "Extracting brain and creating mask.."
${fsl_path}/bet \
        ${output_directory}/${subject_id}/TP1_reor_ss.nii.gz \
        ${output_directory}/${subject_id}/brain_A.nii.gz \
        -m \
        -v \
        -R \
        -n
${fsl_path}/bet \
        ${output_directory}/${subject_id}/TP2_reor_ss.nii.gz \
        ${output_directory}/${subject_id}/brain_B.nii.gz \
        -m \
        -v \
        -R \
        -n


# Intensity nonuniformity:  ANTs N4BiasFieldCorrection
echo "Correcting for intensity nonuniformity.."
${ants_path}/N4BiasFieldCorrection \
        -d 3 \
        -i ${output_directory}/${subject_id}/brain_A.nii.gz \
        -o [ ${output_directory}/${subject_id}/brain_A_N4.nii.gz, ${output_directory}/${subject_id}/brain_A_BiasField.nii.gz ] \
        -x ${output_directory}/${subject_id}/brain_A_mask.nii.gz \
        -v
${ants_path}/N4BiasFieldCorrection \
        -d 3 \
        -i ${output_directory}/${subject_id}/brain_B.nii.gz \
        -o [ ${output_directory}/${subject_id}/brain_B_N4.nii.gz, ${output_directory}/${subject_id}/brain_B_BiasField.nii.gz ] \
        -x ${output_directory}/${subject_id}/brain_B_mask.nii.gz \
        -v


# Linear Registration:      FSL flirt
echo "Registrating linearly with 12 degrees of freedom.."
${fsl_path}/flirt \
        -in ${output_directory}/${subject_id}/brain_A_N4.nii.gz \
        -ref ${template} \
        -dof 12 \
        -out ${output_directory}/${subject_id}/brain_A_N4_flirt.nii.gz \
        -v \
        -omat ${output_directory}/${subject_id}/brain_A_N4_2_template.mat 
${fsl_path}/flirt \
        -in ${output_directory}/${subject_id}/brain_B_N4.nii.gz \
        -ref ${template} \
        -dof 12 \
        -out ${output_directory}/${subject_id}/brain_B_N4_flirt.nii.gz \
        -v \
        -omat ${output_directory}/${subject_id}/brain_B_N4_2_template.mat 


# Reformat affine matrix:   C3D c3d_affine_tool
echo "Reformatting affine matrix.."
${c3d_path}/c3d_affine_tool \
        -ref $template \
        -src ${output_directory}/${subject_id}/brain_A_N4_flirt.nii.gz ${output_directory}/${subject_id}/brain_A_N4_2_template.mat \
        -fsl2ras \
        -oitk ${output_directory}/${subject_id}/brain_A_N4_2_template_itk.mat 
${c3d_path}/c3d_affine_tool \
        -ref $template \
        -src ${output_directory}/${subject_id}/brain_B_N4_flirt.nii.gz ${output_directory}/${subject_id}/brain_B_N4_2_template.mat \
        -fsl2ras \
        -oitk ${output_directory}/${subject_id}/brain_B_N4_2_template_itk.mat 


# Nonlinear registration:   ANTs antsRegistration
echo "Registrating nonlinearly.."
${ants_path}/antsRegistration \
        -d 3 \
        --float 1 \
        --verbose 1 \
        -u 1 \
        -w [ 0.01,0.99 ] \
        -z 1 \
        --initial-moving-transform ${output_directory}/${subject_id}/brain_A_N4_2_template_itk.mat \
        -t SyN[ 0.1,3,0 ]  \
        -m CC[${template},${output_directory}/${subject_id}/brain_A_N4_flirt.nii.gz,1,4 ] \
        -c [ 100x100x70x20,1e-9,10 ] \
        -f 6x4x2x1 \
        -s 4x2x1x0vox \
        -o ${output_directory}/${subject_id}/brain_A_2_template_
${ants_path}/antsRegistration \
        -d 3 \
        --float 1 \
        --verbose 1 \
        -u 1 \
        -w [ 0.01,0.99 ] \
        -z 1 \
        --initial-moving-transform ${output_directory}/${subject_id}/brain_B_N4_2_template_itk.mat \
        -t SyN[ 0.1,3,0 ]  \
        -m CC[${template},${output_directory}/${subject_id}/brain_B_N4_flirt.nii.gz,1,4 ] \
        -c [ 100x100x70x20,1e-9,10 ] \
        -f 6x4x2x1 \
        -s 4x2x1x0vox \
        -o ${output_directory}/${subject_id}/brain_B_2_template_


# Creating warped image:    ANTs antsApplyTransforms 
echo "Creating deformed brain image.."
${ants_path}/antsApplyTransforms \
        -d 3 \/home/lucjon/ants/bin/
        -i ${output_directory}/${subject_id}/brain_A_N4_flirt.nii.gz \
        -r ${template} \
        -t ${output_directory}/${subject_id}/brain_A_2_template_1Warp.nii.gz \
        -t ${output_directory}/${subject_id}/brain_A_2_template_0GenericAffine.mat \
        -o ${output_directory}/${subject_id}/brain_A_2_template_Deformed.nii.gz
${ants_path}/antsApplyTransforms \
        -d 3 \
        -i ${output_directory}/${subject_id}/brain_B_N4_flirt.nii.gz \
        -r ${template} \
        -t ${output_directory}/${subject_id}/brain_B_2_template_1Warp.nii.gz \
        -t ${output_directory}/${subject_id}/brain_B_2_template_0GenericAffine.mat \
        -o ${output_directory}/${subject_id}/brain_B_2_template_Deformed.nii.gz
        
        
# Merge affine and nonlinear transformation: ANTs antsApplyTransforms
echo "Merging affine and nonlinear transformation.."
${ants_path}/antsApplyTransforms \
        -d 3 \
        -t ${output_directory}/${subject_id}/brain_A_2_template_1Warp.nii.gz \
        -t ${output_directory}/${subject_id}/brain_A_2_template_0GenericAffine.mat \
        -r ${template} \
        -o [${output_directory}/${subject_id}/brain_A_2_template_composite_warp.nii.gz,1] \
        -v
${ants_path}/antsApplyTransforms \
        -d 3 \
        -t ${output_directory}/${subject_id}/brain_B_2_template_1Warp.nii.gz \
        -t ${output_directory}/${subject_id}/brain_B_2_template_0GenericAffine.mat \
        -r ${template} \
        -o [${output_directory}/${subject_id}/brain_B_2_template_composite_warp.nii.gz,1] \
        -v
        
  
# Create JD image:          ANTs CreateJacobianDeterminantImage
echo "Creating jacobian determinant image.."
${ants_path}/CreateJacobianDeterminantImage \
        3 \ # dimensions
        ${output_directory}/${subject_id}/brain_A_2_template_composite_warp.nii.gz \
        ${output_directory}/${subject_id}/brain_A_2_template_Jacobian.nii.gz \
        0 \ # not logscaling
        1   # not normalizing
${ants_path}/CreateJacobianDeterminantImage \
        3 \
        ${output_directory}/${subject_id}/brain_B_2_template_composite_warp.nii.gz \
        ${output_directory}/${subject_id}/brain_B_2_template_Jacobian.nii.gz \
        0 \ 
        1  

        
