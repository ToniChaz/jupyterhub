# Copyright (c) Toni Chaz.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/minimal-notebook

LABEL maintainer="Toni Chaz <toni.chaz@hotmail.com>"

USER root

# ffmpeg for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip \
    wget \
    curl \
    ssh \
    iputils-ping \
    ffmpeg \
    libpq-dev \
    python-dev \
    libaio1 \
    libaio-dev \
    libxtst6 \
    libgconf-2-4 \
    xvfb && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID
RUN export NODE_OPTIONS=--max-old-space-size=4096

# Install Python 3 packages
RUN conda install --quiet --yes \
    'beautifulsoup4' \
    'conda-forge::blas=*=openblas' \
    'bokeh' \
    'cloudpickle' \
    'cython' \
    'dask' \
    'dill' \
    'h5py' \
    'hdf5' \
    'ipywidgets' \
    'matplotlib-base' \
    'numba' \
    'numexpr' \
    'pandas' \
    'patsy' \
    'protobuf' \
    'scikit-image' \
    'scikit-learn' \
    'scipy' \
    'seaborn' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy' \
    'vincent' \
    'xlrd' \
    'jupytext' \
    'jupyterlab' \
    'icalendar' \
    'scikit-learn' \
    'psutil' \
    'xhtml2pdf'

RUN conda install --quiet --yes -c plotly chart-studio plotly-orca

RUN conda clean --all -f -y && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Jupyter widgets extension
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    #jupyter labextension install jupyterlab_bokeh --no-build && \
    # FigureWidget support
    jupyter labextension install plotlywidget --no-build && \
    # and jupyterlab renderer support
    jupyter labextension install jupyterlab-plotly --no-build && \
    jupyter lab build && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN unset NODE_OPTIONS

# Install facets which does not have a pip or conda package at the moment
RUN cd /tmp && \
    git clone https://github.com/PAIR-code/facets.git && \
    cd facets && \
    jupyter nbextension install facets-dist/ --sys-prefix && \
    cd && \
    rm -rf /tmp/facets && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

# Install nbgitpuller psycopg2 elasticsearch-dsl unidecode nltk wordcloud
RUN pip install psycopg2 elasticsearch-dsl unidecode nltk wordcloud

USER $NB_UID

