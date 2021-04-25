//ABSTRACT : parameter driven dovetail joins that aren't exactly correct yet due to what I think is a rounding error

// given y,z and upper and lower x dimensions, create a dovetail tail
module dovetail_tail_from_dim (big_x= 20,small_x= 10 ,y=20,z=2,){
	block = big_x + y;
	dif = (big_x - small_x);
	//rounding error?
	degrees = acos((dif/2) /y);
	//echo("degrees : ", degrees);
	intersection(){
			translate([-big_x/4,0,0])
					color("green")
					cube([big_x,y ,z]);
			union(){
					//left
					intersection(){
							//edge
							color("orange")
							rotate(90 - degrees)
											cube([block,block ,z]);
							//mask
							translate([- (small_x + big_x),0,0])
									color("red")
											cube([small_x + big_x,y ,z ]);
					}
					//right
					intersection(){
							//edge
							translate([small_x,0,0])
									color("orange")
											rotate(degrees)
													cube([block*2,block ,z]);
							//mask
							color("red")
									cube([small_x + big_x,y ,z	]);
					}
					//center
					cube([small_x,y ,z]);
			}
	}

}
// given y,z and upper and lower x dimensions, create a dovetail pin socket
module dovetail_pin_from_dim (outer_x = 15, big_x= 10,small_x= 5 ,y=10,z=2,){
	difference(){
			//block to cut
			color("blue")
					cube([outer_x,y,z]);
			translate([(outer_x/2) -	big_x/4 ,0,0])
				color("red")
					dovetail_tail_from_dim(big_x,small_x,y,z);
	}
}

module dovetail_pin_edge_from_count (x = 100, y=10,z=2, count = 3){
	element_x = floor(x/count);
	//echo(max_x);
	pin_big_x = floor(element_x/1.5);
	//echo(pin_big_x);
	// specify ratio?
	pin_small_x = pin_big_x * 0.5;
	//echo(pin_small_x);
	wastage = x - (element_x * count);
	cube([wastage,y,z]);
	for(i = [0: count -1] ){
			offset_position = (wastage /2) + (element_x * i );
			translate([offset_position,0,0]){
				dovetail_pin_from_dim(
						outer_x = element_x,
						big_x = pin_big_x,
						small_x = pin_small_x,
						y = y,
						z = z
				);
			}
	}
	translate([(wastage /2) + (element_x * count ),0,0]){
		cube([wastage,y,z]);
	}


}

module dovetail_tail_edge_from_count (x = 100, y=10,z=2, count = 3){
	max_x = floor(x/count);
	//echo(max_x);
	pin_big_x = floor(max_x/1.5);
	//echo(pin_big_x);
	// specify ratio?
	pin_small_x = pin_big_x * 0.5;
	//echo(pin_small_x);
	wastage = x - (max_x * count);
	for(i = [0: count -1] ){
			offset_position = (wastage /2) + (max_x * i ) + (max_x/2 - pin_big_x/4);
			translate([offset_position,0,0])
					color("blue")
					dovetail_tail_from_dim(pin_big_x,pin_small_x,y,z);
	}

}
//the pin sockets required to join a panel - usually needs dovetail_panel_edge_wastage with the same params to make a solid connection
module dovetail_pin_panel_edge (
	panel_x = 200,
	panel_y = 100,
	z = 4,
	work_x = 150,
	work_y = 4,
	count = 10,
){
	work_offset = (panel_x - work_x)/2;
	translate([work_offset,0,0]){
		dovetail_pin_edge_from_count(work_x,work_y,z,count);
	}
}


// the tails required to join a panel
module dovetail_tail_panel_edge (
	panel_x = 200,
	panel_y = 100,
	z = 4,
	work_x = 150,
	work_y = 4,
	count = 10,
){
	work_offset = (panel_x - work_x)/2;
	color("orange")
		translate([work_offset,z,0]){
			rotate([90,0,0])
				dovetail_tail_edge_from_count(work_x,work_y,z,count);
	}
}

module dovetail_panel_edge_wastage (
	panel_x = 200,
	panel_y = 100,
	z = 4,
	work_x = 150,
	work_y = 4,
	count = 10,
){
	work_offset = (panel_x - work_x)/2;
	difference(){
		color("orange")
			cube([panel_x,work_y,z]);
		color("red")
			translate([work_offset,0,0])
					cube([work_x,work_y,z]);
	}
}

// clockwise, a panel with pin sockets on all sides
module pppp_panel (
	panel_x = 200,
	panel_y = 100,
	count_x = 10,
	count_y = 5,
	work_x = 180,
	work_y = 80,
	z = 4,
	dim = 4,
){
	union(){
		color("green")
			translate([dim,dim,0])
				cube([panel_x - (dim*2),panel_y - (dim*2),z]);
		color("orange")
	// 	12
		translate([0,panel_y ,dim])
			rotate([180,0,0])
			union(){
				dovetail_pin_panel_edge(
					panel_x = panel_x,
					panel_y = panel_y,
					work_x = work_x,
					work_y = dim,
					count = count_x,
					z = z
				);
				echo(panel_x);
				dovetail_panel_edge_wastage(
					panel_x = panel_x,
					panel_y = panel_y,
					work_x = work_x,
					work_y = dim,
					z = z
				);

			}
	// 	3
		translate([0,0,dim])
			rotate([180,0,90])
					union(){
						dovetail_pin_panel_edge(
								panel_x = panel_y,
								panel_y = panel_x,
								work_x = work_y,
								work_y = dim,
								count = count_y,
								z = z
						);
						dovetail_panel_edge_wastage(
								panel_x = panel_y,
								panel_y = panel_x,
								work_x = work_y,
								work_y = dim,
								z = z
						);

					}
	// 	6
		union(){
				dovetail_pin_panel_edge(
						panel_x = panel_x,
						panel_y = panel_y,
						work_x = work_x,
						work_y = dim,
						count = count_x,
						z = z
				);
				dovetail_panel_edge_wastage(
						panel_x = panel_x,
						panel_y = panel_y,
						work_x = work_x,
						work_y = dim,
						z = z
				);

		}
		//9
		translate([panel_x,0 ,0])
		rotate([0,0,90])
				union(){
					dovetail_pin_panel_edge(
						panel_x = panel_y,
						panel_y = panel_x,
						work_x = work_y,
						work_y = dim,
						count = count_y,
						z = z
					);
					dovetail_panel_edge_wastage(
						panel_x = panel_y,
						panel_y = panel_x,
						work_x = work_y,
						work_y = dim,
						z = z
					);
				}
	}
}


// clockwise, a panel with a flat top, pins on the lateral sides, and tails on the bottom side. For the grabbing edge
module bptp_panel (
	panel_x = 200,
	panel_y = 100,
	count_x = 10,
	count_y = 5,
	work_x = 180,
	work_y = 80,
	z = 4,
	dim = 4,
){
	union(){
		color("green")
			translate([dim,dim,0])
				cube([panel_x - (dim*2),panel_y - (dim*2),z]);
		color("orange")
	// 	12
		translate([dim,panel_y -dim,0]){
			cube([panel_x - (dim*2),dim,z]);
		}
		difference(){

			union(){
			// 	3
				translate([0,0,dim])
					rotate([180,0,90])
							union(){
								dovetail_pin_panel_edge(
										panel_x = panel_y,
										panel_y = panel_x,
										work_x = work_y,
										work_y = dim,
										count = count_y,
										z = z
								);
								dovetail_panel_edge_wastage(
										panel_x = panel_y,
										panel_y = panel_x,
										work_x = work_y,
										work_y = dim,
										z = z
								);

							}
			// 	6

					dovetail_tail_panel_edge(
							panel_x = panel_x,
							panel_y = panel_y,
							work_x = work_x,
							work_y = dim,
							count = count_y,
							z = z
					);



				//9
				translate([panel_x,0 ,0])
				rotate([0,0,90])
						union(){
							dovetail_pin_panel_edge(
								panel_x = panel_y,
								panel_y = panel_x,
								work_x = work_y,
								work_y = dim,
								count = count_y,
								z = z
							);
							dovetail_panel_edge_wastage(
								panel_x = panel_y,
								panel_y = panel_x,
								work_x = work_y,
								work_y = dim,
								z = z
							);
						}
			}
			dovetail_panel_edge_wastage(
				panel_x = panel_x,
				panel_y = panel_y,
				work_x = work_x,
				work_y = dim,
				z = z
			);
		}
	}
}
// clockwise, a panel with a flat top, and tails on all other sides. For the general structure elements
module bttt_panel (
	panel_x = 200,
	panel_y = 100,
	count_x = 10,
	count_y = 5,
	work_x = 180,
	work_y = 80,
	z = 4,
	dim = 4,
){
	union(){
		color("green")
			translate([dim,dim,0])
				cube([panel_x - (dim*2),panel_y - (dim*2),z]);
		color("orange")
	// 	12
		translate([dim,panel_y -dim,0]){
			cube([panel_x - (dim*2),dim,z]);
		}

			//3
		translate([panel_x,0 ,0]){
			rotate([0,0,90]){
				dovetail_tail_panel_edge(
					panel_x = panel_y,
					panel_y = panel_x,
					work_x = work_y,
					work_y = dim,
					count = count_y,
					z = z
				);
			}
		}

		// 	6
		dovetail_tail_panel_edge(
				panel_x = panel_x,
				panel_y = panel_y,
				work_x = work_x,
				work_y = dim,
				count = count_x,
				z = z
		);




			//9
		translate([dim,0,0]){
			rotate([0,0,90]){
				dovetail_tail_panel_edge(
					panel_x = panel_y,
					panel_y = panel_x,
					work_x = work_y,
					work_y = dim,
					count = count_y,
					z = z
				);
			}
		}
	}

}

module dovetail_box (
	inner_x = 300,
	inner_y = 200,
	inner_z = 500,
	wall_thickness = 12,
){
	margin = 20;
	width = inner_x + (wall_thickness * 2);
	depth = inner_y + (wall_thickness * 2);
	height = inner_z + wall_thickness;

	//todo learn how to do an if statement
	width_pins = floor(inner_x / 25);
	depth_pins = floor(inner_y / 25);
	height_pins = floor(inner_z / 25);


	width_work = floor(width * .8);
	depth_work = floor(depth * .8);
	height_work = floor(height * .8);

	translate([0,0,0]){
	union(){
					//floor

						pppp_panel(
								panel_x = width,
								panel_y = depth,
								work_x = width_work,
								work_y = depth_work,
								count_x = width_pins,
								count_y = depth_pins,
								z = wall_thickness,
								dim = wall_thickness


						);
					}
// 					//12
						translate([0,depth + margin,margin]){
								rotate([90,0,0]){
									bttt_panel(
											panel_x = width,
											panel_y = height,
											work_x = width_work,
											work_y = height_work,
											count_x = width_pins,
											count_y = height_pins,
								z = wall_thickness,
								dim = wall_thickness
									);
								}
						}
// 					//3
					translate([ width + margin, depth,margin]){
							rotate([90,0,270]){
									bptp_panel(
											panel_x = depth,
											panel_y = height,
											work_x = depth_work,
											work_y = height_work,
											count_x = depth_pins,
											count_y = height_pins,
								z = wall_thickness,
								dim = wall_thickness
									);
							}
					}
					//6
					translate([width,-margin,margin]){
							rotate([90,0,180]){
									bttt_panel(
											panel_x = width,
											panel_y = height,
											work_x = width_work,
											work_y = height_work,
											count_x = width_pins,
											count_y = height_pins,
								z = wall_thickness,
								dim = wall_thickness
									);
							}
					}
//
// 					//9
					translate([-margin,0,margin]){
							rotate([90,0,90]){
									bptp_panel(
											panel_x = depth,
											panel_y = height,
											work_x = depth_work,
											work_y = height_work,
											count_x = depth_pins,
											count_y = height_pins,
								z = wall_thickness,
								dim = wall_thickness
									);
							}
					}
	}
}
