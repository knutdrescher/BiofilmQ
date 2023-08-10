# BiofilmQ Documentation Files

The official BiofilmQ [documentation](https://drescherlab.org/data/biofilmQ/docs/) can be found on the drescherlab [website](https://drescherlab.org/).

#### How to build the documentation locally (on Windows)

1.) Install a python environment with sphinx (i.e. Anaconda3)
- Download [Anaconda3](https://www.anaconda.com/distribution/)
- Install Anaconda3 with the default settings
- Open the just installed Anaconda Prompt and type:

```conda create -n sphinx python pip sphinx```

2.) Find out location of *sphinx-build.exe*
- Should be present under
```<Anaconda3 Installation Path>\envs\sphinx\Scripts\sphinx-build.exe```

3.) Create environemnt variable *SPHINXBUILD* with the full path of sphinx-build.exe as value

4.) Drag and drop the file *make.bat* from this directory in a cmd window and add `html` as first parameter

5.) New build will start and output can be found in `.\_build\html`