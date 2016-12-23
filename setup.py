from setuptools import setup

setup(
    name="infoline",
    version="0.1.2",
    author="Petri Heinilä",
    author_email="hevi00@gmail.com",
    url="https://github.com/hevi9/infoline-zsh-theme",
    packages=["infoline"],
    install_requires=[
        "psutil",
        "gitpython"
    ]

)
