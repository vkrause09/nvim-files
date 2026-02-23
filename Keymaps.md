# KEYMAPS
## Non comprehensive list of keymaps that DIFFER from native nvim
### NOTE: pressing space is what is known as leader for keymaps
```
MODE:       KEY:            Action:
normal      <leader>pv      exit file to file viewer
insert      jk              insert -> normal mode
visual      jk              visual -> normal mode
insert      <C-c> (ctrl-c)  insert -> normal mode
normal      <leader>yy      copies the current line and pastes it below
normal      <leader>yk      copies the current line and pastes it above
normal      <leader>r       runs the current file
visual      J (shift-j)     moves the current line down             
visual      K (shift-k)     moves the current line up             
normal      J (shift-j)     moves the line below to the line you are on 
normal      <C-d> (ctrl-d)  moves cursor to the bottom of the file
normal      <C-u> (ctrl-u)  moves cursor to the topbottom of the file
normal      n               next instanace of / search
normal      N               previous instance of / search            
normal      <leader>f       formats current file
normal      <leader>s       replaces the current word with whatever you type

normal      <C-_> (ctrl-/)  comments out the current line of code
visual      <C-_> (ctrl->)  comments out the current selection (language dependent)
normal      <leader>gs      shows git status

normal      <leader>i       adds file to harpoon quick access
normal      <C-e> (ctrl-e)  opens buffer that shows harpoon quick access
normal      <C-h> (ctrl-h)  opens first file in quick access
normal      <C-j> (ctrl-j)  opens second file in quick access
normal      <C-k> (ctrl-k)  opens third file in quick access
normal      <C-l> (ctrl-l)  opens fourth file in quick access

normal      <C-Space>       shows hints
normal      <Tab>           cycles hint          
normal      <shift-Tab>     cycles previous hint
normal      K               quick shows function
normal      gd              go to definition
normal      gD              go to declaration
normal      gi              go to implementation
normal      gt              go to type
normal      gr              go to reference
normal      <C-h>           get singnature help

normal      <leader>pf      find files
normal      <C-p>           find git files
normal      <leader>ps      grep search for word

normal      u               undo
normal      <leader>u       show undo tree


```
