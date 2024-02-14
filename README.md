# Wheels-Animation
Using assembly language and opengl, this program will animate a rotating wheel divided into three sections. <br><br>
A makefile is added to compile the files using `make wheels` will compile. <br>
Usage: `<executable> -sp <septNumber> -cl <septNumber> -sz <septNumber>` <br>

The program will error-check the command line and convert the septenary number into an integer. 
The first section will be the speed of the animation, the second section will be the color, and the third will be the size 
of the window that opens for the animation. <br>

Note the following max and min values for septenary <br>
SPEED MIN	=	1 <br>
SPEED MAX	= 50,			   101(7) = 50 <br>
COLOR MIN	=	0 <br>
COLOR MAX	=	0xFFFFFF,	 0xFFFFFF = 262414110(7) <br>
SIZE MIN	= 100,			   202(7) = 100 <br>
SIZE MAX	= 2000,			 5555(7) = 2000 <br>

Example Usage: `./wheels -sp 021 -cl 164623 -sz 1000` <br>
Where the speed is converted to 15, the color would be 0x008080 which would be teal, and the size is 343
