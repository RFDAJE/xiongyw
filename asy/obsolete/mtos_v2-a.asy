
import fontsize;
import "node.asy" as node;

settings.tex = "xelatex";
 

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimSun}");


/* we use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);




/* ################ directory tree ################ */

real   font_size = 10;      /* font size */

string dir = "d";
string file = "f";

/* 
 * sample node draw function to draw folder 
 * icon around directory names, as shown below:
 *
 *          _______
 *         /       \
 *        +------------------+
 *        |                  |
 *        | mydirectoryname  |
 *        |                  |
 *        +------------------+
 */
picture dir_draw_func(node p)
{
	picture pic;
	real mini_h = font_size; 
	real margin = 2 ; /* h & v margins */
  pair min, max;

  label(pic, "\texttt{"+p.text+"}");
  
  
   /* get the text dimension */
   min = min(pic);
   max = max(pic);
   
   /* make sure the height is at least min_h */
   if((max.y - min.y) < mini_h){
       real delta = (mini_h - (max.y - min.y)) / 2;
       max = (max.x, max.y + delta);
       min = (min.x, min.y - delta);
   }
   
   /* take margin into account */
   min -= (margin, margin);
   max += (margin, margin);
   
   /* draw the box */
   draw(pic, min--(min.x, max.y)--max--(max.x, min.y)--cycle,  p.priv == dir? defaultpen : invisible);

   /* draw the folder part */
   draw(pic, (min.x, max.y)--(min.x+2, max.y+2)--(min.x+8, max.y+2)--(min.x+10, max.y), p.priv == dir? defaultpen : invisible);

   return pic;
}


node dir_etc                     = node("$\cdots$", "d");
node file_etc                    = node("$\cdots$", "f");node N09cf6008 = node("../dirtree", "d");

node N09473008 = node("mtos_v2", "d");
node N0947b050 = node("products", "d");
node N09483098 = node("librasd", "d");
node N0948b0e0 = node("misc.c", "f");
N09483098.attach(N0948b0e0);
node N0948b108 = node("Vector_gnu.S", "f");
N09483098.attach(N0948b108);
N0947b050.attach(N09483098);
N09473008.attach(N0947b050);
node N0947b078 = node("sys", "d");
node N0947b0a0 = node("arch", "d");
node N0947b0c8 = node("arm", "d");
node N0947b0f0 = node("arm926ejs", "d");
node N0947b118 = node("avl_cache.c", "f");
N0947b0f0.attach(N0947b118);
node N0947b140 = node("avl_processor.c", "f");
N0947b0f0.attach(N0947b140);
node N0947b170 = node("avl_cpsr_gnu.S", "f");
N0947b0f0.attach(N0947b170);
node N0947b1a0 = node("Vector.c", "f");
N0947b0f0.attach(N0947b1a0);
node N0947b1c8 = node("avl_string_gnu.S", "f");
N0947b0f0.attach(N0947b1c8);
node N0947b1f8 = node("avl_mmu.c", "f");
N0947b0f0.attach(N0947b1f8);
N0947b0c8.attach(N0947b0f0);
N0947b0a0.attach(N0947b0c8);
N0947b078.attach(N0947b0a0);
node N0947b220 = node("common", "d");
node N0947b248 = node("avl_test_profile.c", "f");
N0947b220.attach(N0947b248);
node N0947b278 = node("avl_time.c", "f");
N0947b220.attach(N0947b278);
node N0947b2a0 = node("avl_malloc.c", "f");
N0947b220.attach(N0947b2a0);
node N0947b2d0 = node("wrapper", "d");
node N0947b2f8 = node("mtos", "d");
node N0947b320 = node("avl_wrapper_event.c", "f");
N0947b2f8.attach(N0947b320);
node N0947b350 = node("avl_wrapper_cond.c", "f");
N0947b2f8.attach(N0947b350);
node N0947b380 = node("avl_timer.c", "f");
N0947b2f8.attach(N0947b380);
node N0947b3a8 = node("avl_wrapper_queue.c", "f");
N0947b2f8.attach(N0947b3a8);
node N0947b3d8 = node("avl_wrapper_misc.c", "f");
N0947b2f8.attach(N0947b3d8);
node N0947b408 = node("avl_wrapper_mutex.c", "f");
N0947b2f8.attach(N0947b408);
node N0947b438 = node("avl_wrapper_semaphore.c", "f");
N0947b2f8.attach(N0947b438);
node N0947b470 = node("avl_wrapper_thread.c", "f");
N0947b2f8.attach(N0947b470);
node N0947b4a8 = node("avl_std_lowio.c", "f");
N0947b2f8.attach(N0947b4a8);
node N0947b4d8 = node("avl_wrapper_flag.c", "f");
N0947b2f8.attach(N0947b4d8);
N0947b2d0.attach(N0947b2f8);
N0947b220.attach(N0947b2d0);
node N0947b508 = node("common", "d");
node N0947b530 = node("avl_queue.c", "f");
N0947b508.attach(N0947b530);
node N0947b558 = node("avl_linked_list.c", "f");
N0947b508.attach(N0947b558);
N0947b220.attach(N0947b508);
N0947b078.attach(N0947b220);
node N0947b588 = node("os", "d");
node N0947b5b0 = node("mtos_sd", "d");
node N0947b5d8 = node("Ports", "d");
node N0947b600 = node("ARM", "d");
node N0947b628 = node("Generic", "d");
node N0947b650 = node("os_string.cpp", "f");
N0947b628.attach(N0947b650);
node N0947b680 = node("os_port.cpp", "f");
N0947b628.attach(N0947b680);
node N0947b6a8 = node("os_port_gnu.S", "f");
N0947b628.attach(N0947b6a8);
N0947b600.attach(N0947b628);
N0947b5d8.attach(N0947b600);
N0947b5b0.attach(N0947b5d8);
node N0947b6d8 = node("mem", "d");
node N0947b700 = node("mem_cpp.cpp", "f");
N0947b6d8.attach(N0947b700);
node N0947b728 = node("mem_adv.cpp", "f");
N0947b6d8.attach(N0947b728);
N0947b5b0.attach(N0947b6d8);
node N0947b750 = node("Source", "d");
node N0947b778 = node("os_core.cpp", "f");
N0947b750.attach(N0947b778);
node N0947b7a0 = node("os_event.cpp", "f");
N0947b750.attach(N0947b7a0);
node N0947b7d0 = node("os_semaphore.cpp", "f");
N0947b750.attach(N0947b7d0);
node N0947b800 = node("os_mailbox.cpp", "f");
N0947b750.attach(N0947b800);
node N0947b830 = node("os_mutex.cpp", "f");
N0947b750.attach(N0947b830);
node N0947b860 = node("os_object.cpp", "f");
N0947b750.attach(N0947b860);
node N0947b890 = node("os_thread.cpp", "f");
N0947b750.attach(N0947b890);
node N0947b8c0 = node("os_cond.cpp", "f");
N0947b750.attach(N0947b8c0);
node N0947b8e8 = node("os_flag.cpp", "f");
N0947b750.attach(N0947b8e8);
node N0947b910 = node("os_queue.cpp", "f");
N0947b750.attach(N0947b910);
N0947b5b0.attach(N0947b750);
N0947b588.attach(N0947b5b0);
N0947b078.attach(N0947b588);
N09473008.attach(N0947b078);
picture root = draw_tree(N09473008, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);