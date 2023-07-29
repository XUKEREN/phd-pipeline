# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html
import os
import sys
sys.path.insert(0, os.path.abspath('./')) # or "../../src
# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'phd-pipeline'
copyright = '2023, Keren Xu'
author = 'Keren Xu'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.autodoc',  # automatically generate documentation for modules
    'sphinx.ext.autosummary', # generate autodoc summaries
    'sphinx.ext.intersphinx', # link to other projects' documentation
    'sphinx.ext.mathjax',
    'sphinx.ext.napoleon',  # read Google-style or Numpy-style docstrings
    'sphinx.ext.viewcode',  # allow viewing the source code in the web page
    'myst_nb', # parse notebook
    'sphinx_remove_toctrees', # selectively remove TocTree objects from pages 
    'sphinx_copybutton', # add a "copy" button to code blocks
    'sphinx_design', # design beautiful, view size responsive web components
]

templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = [
    './*/*.md',
    'README.md'
]

# The suffix of source filenames
source_suffix = ['.rst', '.ipynb', '.md']

# The encoding of source files
source_encoding = 'utf-8'

# The main toctree document
root_doc = 'index'

suppress_warnings = [
    'myst.header',
    'myst.reference',
]

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
# add_module_names = True
add_module_names = False

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
# show_authors = False

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = None

autosummary_generate = True

# If true, keep warnings as "system message" paragraphs in the built documents.
# keep_warnings = False

# Napoleon settings
napoleon_google_docstring = True
napoleon_numpy_docstring = True
# napoleon_include_init_with_doc = False
# napoleon_include_private_with_doc = False
# napoleon_include_special_with_doc = True
# napoleon_use_admonition_for_examples = False
# napoleon_use_admonition_for_notes = False
# napoleon_use_admonition_for_references = False
# napoleon_use_ivar = False
# napoleon_use_param = True
# napoleon_use_rtype = True
# napoleon_preprocess_types = False
# napoleon_type_aliases = None
# napoleon_attr_annotations = True


# -- Options for myst ----------------------------------------------
myst_heading_anchors = 3  # auto-generate 3 levels of heading anchors
myst_enable_extensions = ['dollarmath']
nb_execution_mode = 'off'

# Notebook cell execution timeout; defaults to 30.
nb_execution_timeout = 100


# -- Options for autodoc ----------------------------------------------
# Tell sphinx-autodoc-typehints to generate stub parameter annotations including
# types, even if the parameters aren't explicitly documented.
always_document_param_types = True


# Tell sphinx autodoc how to render type aliases.
autodoc_type_aliases = {
    'ArrayLike': 'ArrayLike',
    'DTypeLike': 'DTypeLike',
}

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_book_theme'
html_static_path = ['_static']
html_theme_options = {
    'show_toc_level': 2,
    'repository_url': 'https://github.com/XUKEREN/phd-pipeline',
    'use_repository_button': True,     # add a "link to repository" button
}

