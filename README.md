# Project

This is a simplified translator from Markdown to HTML, this one does not translate all the elements it's just to learn lex and yacc.

![](./imgReadme.jpg)

This project was made for a 3rd year license study project.

### Features 

- Translates titles with  tags of different levels.
- Translates unnumbered list tags.
- Translates bold and italic text tags.
- Translates paragraph tags.

# Built with 

The project was made in C with Lex and Yacc.

# Get and use project

### Prerequisites

1. You need install Lex and Yacc.
```
apt-get install flex
apt-get install bison
```

### Installation 

1. Clone the repo. 
```
git clone https://github.com/LilianLeVrai/translator_Markdown_to_Html.git
```
2. Compile project with Makefile. 
```
make
```
3. Run by specifying an input file and an output file.
```
./analyzer < inputFile.md > outputFile.html
```
The project being intended for a teacher, the output contains other information than the html such as the lexical units detected, the html result is at the end.
To test the functionalities you have the input file 'test.md'.


# Contributors 

- [Lilian M.](https://github.com/LilianManzano "")
- Nicolas C.



