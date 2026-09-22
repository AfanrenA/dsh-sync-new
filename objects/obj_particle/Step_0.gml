x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);
image_alpha -= 0.05;
if (image_alpha <= 0) instance_destroy();