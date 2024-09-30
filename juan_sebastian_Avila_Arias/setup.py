""" Setup file """
from setuptools import setup
from setuptools import find_packages
from glob import glob
from os.path import splitext
from os.path import basename
import versioneer

setup(
    name = 'vghu-prueba-tecnica-originacion-cobranza',
    description = 'Esta prueba es para medir mis capacidades para la manipulacion de los datos mediante diferentes lenguajes de programacion',
    url = 'https://GrupoBancolombia@dev.azure.com/GrupoBancolombia/Vicepresidencia%20de%20Innovaci%C3%B3n%20y%20Transformaci%C3%B3n%20Digital/_git/vghu-prueba-tecnica-originacion-cobranza',
    author = 'juavila',
    author_email = 'juavila@bancolombia.com.co',
    license = '...',
    packages = find_packages('src'),
    package_dir={'': 'src'},
    py_modules=[splitext(basename(path))[0] for path in glob('src/*.py')],
    python_requires='>=3.9.12',
    entry_points = {
        'console_scripts': ['vghu_prueba_tecnica_originacion_cobranza = vghu_prueba_tecnica_originacion_cobranza.ejecucion:main']
    },
    install_requires = [
        'future_fstrings',
        'orquestador2>=1.3.2',
        'openpyxl'
    ],
    include_package_data = True,
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
)
