transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/turn_direction_logic.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/frequency_scaling.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/ADC_Controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/black_line_following.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/pwm_generator.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/color_sensor.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/led_logic.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/start_detector.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4 {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/uart_rx.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/output_files {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/output_files/SLM.v}
vlog -vlog01compat -work work +incdir+C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/output_files {C:/Users/LeeladithyaSagar/Desktop/eb_1102_task4/output_files/uart_tx.v}

