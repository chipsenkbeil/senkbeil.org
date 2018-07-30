+++
title = "Reducing the Barrier to Entry in Note Taking"
slug = "reducing-the-barrier-to-entry-in-note-taking"
date = "2018-07-01"
categories = [ "tool" ]
tags = [ "zsh" ]
+++

One of my biggest challenges to accomplishing something is the barrier to 
entry. Starting a project, exercising, and even writing this blog post take
genuine effort for me to do. After realizing this as one of my biggest
obstacles to getting things done, I've dedicated quite a few cycles of my time
toward figuring out ways to reduce the initial friction. For the case of taking
notes, this involved both providing a quick way to get started as well as a
comfortable environment to write notes.

For me, the speed aspect revolved around having a simple interface to launch
new notes and resume existing ones. Given that I often find myself in a
terminal during work, my focus was on using a quick command like 
`notes blogpost` to start or resume a blog post.

For comfort, I sought to use vim to edit my notes. I use it for my daily
editing and prefer having the familiar modes of editing compared to launching a
plain text editor. This meant that a command like `notes blogpost` should open
vim to allow me to create/edit a file and exit in the same manner as I would
any vim file.

## The Solution

Enter the zsh function: notes. I use zsh as my shell purely out of a desire for
some more robust completion, file renaming, and prompt tweaking. Rather than
creating a separate program that would need to be installed and added to my path
on every computer I use, I decided that creating a function to be exposed by my
shell would be the simplest way to have the functionality I wanted.

The function needed to do two things: provide a standard place to store my note
files and open those files using vim. To do this, I decided that my default
location for my notes would be a hidden directory called _.notes_ within my
home directory. Within that directory, each note file would have the markdown
extension of _.md_. The function itself could be provided with the name of the
note file such as _blogpost_ and it would in turn open the corresponding
markdown file (e.g. _blogpost.md_).

```zsh
notes() {
  local base_path="$HOME/.notes"
  mkdir -p "$base_path"

  local note_file="$1.md"
  local note_path="$base_path/$note_file"

  $EDITOR "$note_path"
}
```

The above would create the _.notes_ directory if it did not exist, convert the
provided argument into a file name, and then open the file using my editor,
which was configured earlier in my _.zshrc_ file as `export EDITOR="nvim"`.

From here, I could quickly jump into vim without the need to navigate to a
note-taking directory or specify the entire file including the extension. If I
wanted to work on _post-1_, I could type `notes post-1` to open the file.

## The Aftermath

Since creating that tiny function, I began tweaking and expanding what it can
do. This ranged from filling in a new file with a default header to being able
to list existing notes. Given its complexity, I've decided to extract the
function and move it to its own zsh plugin, which you can find at 
[chipsenkbeil/zsh-notes](https://github.com/chipsenkbeil/zsh-notes) on GitHub.

