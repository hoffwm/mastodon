[Mesh]
  type = FileMesh
  file = mesh.e
  patch_update_strategy = iteration  #For contact
  patch_size = 40
  # partitioner = centroid
  # centroid_partitioner_direction = z
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[Adaptivity]
  initial_marker = minimum_element_marker
  initial_steps = 10
  max_h_level = 10
  [./Indicators]
    [./minimum_element_size]
      type = ShearWaveIndicator
      cutoff_frequency = 10
      block = 'soil'
    [../]
  [../]
  [./Markers]
    [./minimum_element_marker]
      type = MinimumElementSizeMarker
      indicator = minimum_element_size
      scale = .1
      block = 'soil'
    [../]
  []
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./accel_x]
  [../]
  [./accel_y]
  [../]
  [./vel_y]
  [../]
  [./vel_z]
  [../]
  [./accel_z]
  [../]
  [./nor_forc]
    order = FIRST
    family = LAGRANGE
  [../]
  [./tang_forc_x]
    order = FIRST
    family = LAGRANGE
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

[Kernels]
  [./TensorMechanics]
    use_displaced_mesh = true
    displacements = 'disp_x disp_y disp_z'
  [../]
  [./gravity]
    type = Gravity
    variable = disp_z
    value = -386.09
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
    eta=0.0
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
    eta=0.0
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.25
    gamma = 0.5
    eta = 0.0
  [../]
[]

[AuxKernels]
  [./nor_forc]
    type = PenetrationAux
    variable = nor_forc
    quantity = normal_force_magnitude
    boundary = 'block_contact_surface'
    paired_boundary = 'soil_contact_surface'
  [../]
  [./tang_forc_x]
    type = PenetrationAux
    variable = tang_forc_x
    quantity = tangential_force_x
    boundary = 'block_contact_surface'
    paired_boundary = 'soil_contact_surface'
  [../]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./hmin]
    type = ElementLengthAux
    variable = hmin
    method = min
    execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  [./fix_x_soil]
    type = PresetBC
    variable = disp_x
    boundary = 'outer_soil_surfaces'
    value = 0.0
  [../]
  [./fix_y_soil]
    type = PresetBC
    variable = disp_y
    boundary = 'outer_soil_surfaces'
    value = 0.0
  [../]
  [./fix_z_soil]
    type = PresetBC
    variable = disp_z
    boundary = 'outer_soil_surfaces'
    value = 0.0
 [../]
 [./concrete_pressure]
    type = Pressure
    boundary = 'block_top_surface'
    variable = disp_z
    component = 2
    factor = 5 #psi
  [../]
  [./top_x]
    type = PresetDisplacement
    boundary = 'concrete_block_all_nodes'
    variable = disp_x
    beta = 0.25
    velocity = vel_x
    acceleration = accel_x
    function = loading_bc
  [../]
[]

[Functions]
  [./loading_bc]
    type = PiecewiseLinear
    data_file = 'input_motion.csv'
    format = columns
  [../]
  [layer_function]
    type = PiecewiseConstant
    x = '16.0 32.0 48.0'
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
  [./elasticity_tensor_block]
    youngs_modulus = 4500 #psi
    poissons_ratio = 0.25
    type = ComputeIsotropicElasticityTensor
    block = 'concrete_block'
  [../]
  [./strain_block]
    type = ComputeFiniteStrain
    block = 'concrete_block'
    displacements = 'disp_x disp_y disp_z'
  [../]
  [./stress_block]
    type = ComputeFiniteStrainElasticStress
    block = 'concrete_block'
  [../]
  [./den_block]
    type = GenericConstantMaterial
    block = 'concrete_block'
    prop_names = density
    prop_values = 0.084 #lb/in^3
  [../]

  [./Elasticity_tensor_soil]
    type = ComputeIsotropicElasticityTensorSoil
    block = 'soil'
    layer_variable = layer
    layer_ids = '0 1 2'
    poissons_ratio = '0.3 0.3 0.3'
    shear_modulus = '1.35e6 5.4e6 2.16e7'
    density = '15   15   15'
  [../]
  [./strain_1]
    type = ComputeSmallStrain
    block = 'soil'
  [../]
  [./stress_1]
    type = ComputeLinearElasticStress
    block = 'soil'
  [../]
[]

[Contact]
  [./leftright]
    slave = 'block_contact_surface'
    master = 'soil_contact_surface'
    system = constraint
    model = coulomb
    formulation = penalty
    normalize_penalty = true
    friction_coefficient = 0.7
    penalty = 1e5
    displacements = 'disp_x disp_y disp_z'
  [../]
[]

[Preconditioning]
  [./andy]
    type = SMP
    full = true
  [../]
[]

[Postprocessors]
  [./nor_forc]
    type = NodalSum
    variable = nor_forc
    boundary = 'block_contact_surface'
  [../]
  [./tang_forc_x]
    type = NodalSum
    variable = tang_forc_x
    boundary = 'block_contact_surface'
  [../]
  [./dispx]
    type = NodalMaxValue
    block = 'concrete_block'
    variable = disp_x
  [../]
[]

[Controls]
  [./inertia_switch]
    type = TimePeriod
    start_time = 0.9
    end_time = 1
    disable_objects = '*/inertia_x */inertia_y */inertia_z */vel_x */vel_y */vel_z */accel_x */accel_y */accel_z'
    set_sync_times = true
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu     superlu_dist'
  line_search = 'none'
  start_time = 0.9
  end_time = 2.5
  dt = 0.005
  dtmin = 0.001
  nl_abs_tol = 1e-1
  nl_rel_tol = 1e-4
  l_tol = 1e-2
  l_max_its = 20
  timestep_tolerance = 1e-3
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
  print_linear_residuals = false
  [./screen]
    type = Console
    max_rows = 1
  [../]
[]
