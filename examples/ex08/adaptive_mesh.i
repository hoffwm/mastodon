[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 3
  ny = 3
  nz = 3
  xmin = 0
  ymin = 0
  zmin = 0
  xmax = 90
  ymax = 90
  zmax = 90
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Adaptivity]
  initial_marker = minimum_element_marker
  initial_steps = 10
  max_h_level = 10
  [./Indicators]
    [./minimum_element_size]
      type = ShearWaveIndicator
      cutoff_frequency = 10
    [../]
  [../]
  [./Markers]
    [./minimum_element_marker]
      type = MinimumElementSizeMarker
      indicator = minimum_element_size
      scale = .1
    [../]
  []
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[Kernels]
  [./stress_div_x]
     type = ADStressDivergenceTensors
     variable = disp_x
     component = 0
  [../]
  [./stress_div_y]
     type = ADStressDivergenceTensors
     variable = disp_y
     component = 0
  [../]
  [./stress_div_z]
     type = ADStressDivergenceTensors
     variable = disp_z
     component = 0
  [../]
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./accel_x]
  [../]
  [./vel_y]
  [../]
  [./accel_y]
  [../]
  [./vel_z]
  [../]
  [./accel_z]
  [../]
  [./layer]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./hmin]
    family = MONOMIAL
    order = CONSTANT
  [../]

[]

[AuxKernels]
  [./hmin]
    type = ElementLengthAux
    variable = hmin
    method = min
    execute_on = 'initial timestep_end'
  [../]
[]

[Functions]
  [layer_function]
    type = PiecewiseConstant
    x = '30.0 60.0 90.0'
    y = '0 1 2'
    direction = right
    axis = z
  []
[]

[ICs]
  [./id_ic]
    type = FunctionIC
    function = layer_function
    variable = layer
  [../]
[]

[Materials]
  [./Elasticity_tensor_1]
    type = ComputeIsotropicElasticityTensorSoil
    block = 0
    layer_variable = layer
    layer_ids = '0 1 2'
    poissons_ratio = '0.3 0.3 0.3'
    shear_modulus = '1.35e6 5.4e6 2.16e7'
    density = '15   15   15'
  [../]
  [./strain_1]
    type = ComputeSmallStrain
    block = 0
  [../]
  [./stress_1]
    type = ComputeLinearElasticStress
    block = 0
  [../]
[]

[BCs]
  [./bottom_x]
    type = DirichletBC
    boundary = bottom
    variable = disp_x
    value = 0.0
  [../]
  [./bottom_y]
    type = DirichletBC
    boundary = bottom
    variable = disp_y
    value = 0.0
  [../]
  [./bottom_z]
    type = DirichletBC
    boundary = bottom
    variable = disp_z
    value = 0.0
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 1
  solve_type = 'PJFNK'
[]

[Outputs]
  exodus = true
[]
