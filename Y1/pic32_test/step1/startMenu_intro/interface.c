
/* interface.c */

#include <string.h>
#include <stddef.h>
#include "interface.h"
#include "button.h"
#include "peripherals.h"
#include "game.h"
#include "icon.h"
#include "functions.h"

#define BUTTONS 4 /* 4 pages/lines available, and as such; 4 buttons */



static Button buttons[BUTTONS]; 
static int selected = 0;
int getsw(void);

/* Draw all buttons with an outline around the currently selected one
 */
void interface_draw(void)
{
	/* Draw buttons */
	for(int i = 0; i < BUTTONS; ++i)
	{
		button_draw(&buttons[i], i);
	}
	
	/* Draw outline around selected button */
	int const page = selected * 8;
	
	for(int y = page; y < page + 8; ++y)
	{
		for(int x = 0; x < DSP_COLUMNS; ++x)
		{
			if((x == 0 || x == DSP_COLUMNS - 1) || (y == page || y == page + 7))
				graphics_set(x, y, 1);
		}
	}
}




/* Press the currently selected button,
 * and reset the selected index
 */
void interface_button_press(void)
{
	button_press(&buttons[selected]);
	
	if(buttons[selected].function != NULL)
		selected = 0;
}


void interface_button_prev(void)
{
	if(--selected < 0)
		selected = BUTTONS - 1;
}


void interface_button_next(void)
{
	if(++selected >= BUTTONS)
		selected = 0;
}


void interface_menu_load_main(void)
{
	state = STATE_MENU_MAIN;
	
	button_cons(&buttons[0], "MAIN MENU",      NULL);
	button_cons(&buttons[1], "TEST GPIO",  interface_menu_load_gpioTest);
	button_cons(&buttons[2], "HIGHSCORES",  NULL);
	button_cons(&buttons[3], "ABOUT", interface_menu_load_about);
}

void interface_menu_load_about(void)
{
	state = STATE_MENU_HELP;
	button_cons(&buttons[0], "BTNX: MOVE           ",  NULL);
	button_cons(&buttons[1], "SW4 : PAUSE          ",  NULL);
	button_cons(&buttons[2], "SW3 : INVERT DISPLAY " , NULL);
	button_cons(&buttons[3], "BACK", interface_menu_load_main);
}

void interface_menu_load_gpioTest(void)
{
    //state = STATE_MENU_TESTGPIO;
    button_cons(&buttons[0], "TEST LEDS", LED_test_start);
    button_cons(&buttons[1], "TEST INPUT",   NULL);
    button_cons(&buttons[2], "TEST DISPLAY ", display_test_start);
    button_cons(&buttons[3], "BACK",    interface_menu_load_main);
}



void interface_menu_load_paused(void)
{
    state = STATE_MENU_PAUSED;
    button_cons(&buttons[0], "PAUSED", NULL);
    button_cons(&buttons[1], "RETURN TO MAIN MENU", interface_menu_load_main);
    button_cons(&buttons[2], "CONTINUE TEST", NULL);
    button_cons(&buttons[3], " ", NULL);

}
