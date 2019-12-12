[Mesh]
  type = FileMesh
  file = mesh.e
[]

[Problem]
  solve = false
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
      shear_wave_speed = shear_wave_speed
    [../]
  [../]
  [./Markers]
    [./minimum_element_marker]
      type = MinimumElementSizeMarker
      indicator = minimum_element_size
      block = 'soil'
    [../]
  []
[]

[AuxVariables]
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
    x = '16.0 32.0 48.0'
    y = '0 1 2'
    direction = right
    axis = z
  []
  [shear_wave_speed_function]
    type = PiecewiseConstant
    x = '16.0 32.0 48.0'
    y = '30 60 120'
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
  [./soil_mat_func]
    type = GenericFunctionMaterial
    block = 'soil'
    prop_names = 'shear_wave_speed'
    prop_values = 'shear_wave_speed_function'
  [../]
  [./concrete]
    type = ParsedMaterial
    function = '1'
    block = 'concrete_block'
  [../]
[]

[Preconditioning]
  [./andy]
    type = SMP
    full = true
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
  execute_on = 'timestep_end'
  exodus = true
[]
