[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  beta = 0.25
  gamma = 0.5
  #alpha = -0.3
[]

[Mesh]
  type = FileMesh
  file = 'glb_model_saa.e'
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
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
  [./layer_id]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./DynamicTensorMechanics]
    #zeta = .01749 #15%
    zeta = .00583 #5%
    #zeta = .002332 #2%
#    alpha = -0.3
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    #eta = .60707 #15%
    eta = 0.2024 #5%
    #eta = 0.08094 #2%
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    #eta = .60707 #15%
    eta = 0.2024 #5%
    #eta = 0.08094 #2%
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    #eta = .60707 #15%
    eta = 0.2024 #5%
    #eta = 0.08094 #2%
  [../]
  [./gravity]
    type = Gravity
    variable = disp_z
    value = -9.81
  [../]
[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = timestep_end
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = timestep_end
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = timestep_end
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = timestep_end
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    execute_on = timestep_end
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    execute_on = timestep_end
  [../]
  [./layer_id]
     type = UniformLayerAuxKernel
     block = '1'
     variable = layer_id
     interfaces = '1.5 2.5 3.5 5.0'
     direction = '0.0 0.0 1.0'
     execute_on = initial
  [../]
[]


[BCs]
  [./base_Accel]
    type = PresetAcceleration
    boundary = '101'
    function = 'accel_func'
    variable = 'disp_x'
    acceleration = 'accel_x'
    velocity = 'vel_x'
  [../]
  [./bottom_y]
    type = DirichletBC
    variable = 'disp_y'
    boundary = '101'
    value = 0.0
  [../]
  [./bottom_z]
    type = DirichletBC
    variable = 'disp_z'
    boundary = '101'
    value = 0.0
  [../]
  [./Periodic]
    [./periodic_x]
      variable = 'disp_x disp_y disp_z'
      primary = '104'
      secondary = '103'
      translation = '0.025 0 0'
    [../]
    [./periodic_y]
      variable = 'disp_x disp_y disp_z'
      primary = '106'
      secondary = '105'
      translation = '0 0.025 0'
    [../]
  [../]
[]


# For Monte Carlo, the sampled variables will be shear_wave_velocity and density.
# If shear wave velocity becomes an input, initial shear/bulk modulus can be calculated internally.
[Materials]
  [./I_Soil]
    [./soil_1]
      block = 1
      soil_type = 1
      layer_variable = layer_id
      layer_ids = '0 1 2 3'
      # shear_wave_velocity = '100 110 120 130' #m/s
      poissons_ratio = '0.3 0.3 0.3 0.3'
      density = '2000 2000 2000 2000'
      initial_stress = 'initial_x_y 0 0 0 initial_x_y 0 0 0 initial_zz'
      pressure_dependency = false
      b_exp = 0.0
      tension_pressure_cut_off = -1
      p_ref = '51619.28571 36437.14286 24291.42857 9109.285714'
      a0 = 1.0
      a1 = 0.0
      a2 = 0.0
      ### Darendeli ###
      number_of_points = 100
      initial_bulk_modulus = '5.5332e7 8.6151e7 8.9856e7 5.2433e7'
      initial_shear_modulus = '25538e3 39762e3 41472e3 24200e3'
      over_consolidation_ratio = '1.0 1.0 1.0 1.0'
      plasticity_index = '1.0 1.0 1.0 1.0'
      ######
    [../]
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  #solve_type = 'NEWTON'
  solve_type = 'PJFNK'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = '201                hypre    boomeramg      4'
  line_search = 'none'
  start_time = 1.3
  end_time = 6.0
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  l_tol = 1e-6
  timestep_tolerance = 1e-10
  dt = 0.001
  #[./TimeStepper]
  #  type = IterationAdaptiveDT
  #  dt = 0.1
  #  force_step_every_function_point = true
  #  timestep_limiting_function = 'accel_func'
  #[../]
[]

[Functions]
  [./accel_func]
    type = PiecewiseLinear
    data_file = 'base_lam_accel_zeropad.csv'
    #data_file = 'X_acc_input8_1.csv'
    format = 'columns'
    scale_factor = 1.0
  [../]
  [./initial_zz]
    type = PiecewiseLinear
    x = '.75 2 3 4.25'
    y = '14715 39240 58860 83385'
    #type = ParsedFunction
    #value = '2000.0 * -9.81 * (5.0 - z)'
  [../]
  [./initial_x_y]
    type = PiecewiseLinear
    x = '.75 2 3 4.25'
    y = '6306.428571 16817.14286 25225.71429 35736.42857'
    #type = ParsedFunction
    #value = '2000.0 * -9.81 * (5.0 - z) * 0.3/0.7'
  [../]
[]

#[VectorPostprocessors]
#  [./accel_hist]
#    type = ResponseHistoryBuilder
#    variables = 'accel_x'
#    node = 402
#    execute_on = 'initial timestep_end'
#  [../]
#  [./accel_spec]
#    type = ResponseSpectraCalculator
#    vectorpostprocessor = accel_hist
#    variables = 'accel_x'
#    damping_ratio = 0.05
#    dt_output = 0.001
#    calculation_time = 4.7
#    execute_on = timestep_end
#  [../]
#[]

[Postprocessors]
  [./_dt]
    type = TimestepSize
  [../]
  [./ACC_21]
    type = PointValue
    point = '0 0 4.8491'
    variable = accel_x
  [../]
  #[./ACC_20]
  #  type = PointValue
  #  point = '0 0 4.6027'
  #  variable = accel_x
  #[../]
  [./ACC_19]
    type = PointValue
    point = '0 0 4.3551'
    variable = accel_x
  [../]
  #[./ACC_18]
  #  type = PointValue
  #  point = '0 0 4.110'
  #  variable = accel_x
  #[../]
  #[./ACC_17]
  #  type = PointValue
  #  point = '0 0 3.861'
  #  variable = accel_x
  #[../]
  [./ACC_16]
    type = PointValue
    point = '0 0 3.613'
    variable = accel_x
  [../]
  #[./ACC_15]
  #  type = PointValue
  #  point = '0 0 3.367'
  #  variable = accel_x
  #[../]
  #[./ACC_14]
  #  type = PointValue
  #  point = '0 0 3.121'
  #  variable = accel_x
  #[../]
  [./ACC_13]
    type = PointValue
    point = '0 0 2.878'
    variable = accel_x
  [../]
  #[./ACC_12]
  #  type = PointValue
  #  point = '0 0 2.630'
  #  variable = accel_x
  #[../]
  #[./ACC_11]
  #  type = PointValue
  #  point = '0 0 2.383'
  #  variable = accel_x
  #[../]
  [./ACC_10]
    type = PointValue
    point = '0 0 2.136'
    variable = accel_x
  [../]
  #[./ACC_09]
  #  type = PointValue
  #  point = '0 0 1.890'
  #  variable = accel_x
  #[../]
  [./ACC_08]
    type = PointValue
    point = '0 0 1.640'
    variable = accel_x
  [../]
  #[./ACC_07]
  #  type = PointValue
  #  point = '0 0 1.3955'
  #  variable = accel_x
  #[../]
  [./ACC_06]
    type = PointValue
    point = '0 0 1.150'
    variable = accel_x
  [../]
  #[./ACC_05]
  #  type = PointValue
  #  point = '0 0 0.90567'
  #  variable = accel_x
  #[../]
  #[./ACC_04]
  #  type = PointValue
  #  point = '0 0 0.65839'
  #  variable = accel_x
  #[../]
  [./ACC_03]
    type = PointValue
    point = '0 0 0.413'
    variable = accel_x
  [../]
  #[./ACC_02]
  #  type = PointValue
  #  point = '0 0 0.178'
  #  variable = accel_x
  #[../]
  [./ACC_01]
    type = PointValue
    point = '0 0 0'
    variable = accel_x
  [../]
  [./num_its]
    type = NumNonlinearIterations
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_linear_residuals = true
  print_perf_log = true
  file_base = out
  [./out]
    type = Console
    interval = 50
  [../]
[]
