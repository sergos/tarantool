import argparse


class Parser:

    def __init__(self) -> None:
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument("-f", "--from-directory", required=True,
                                 help="directory with files to publish")
        self.args = self.parser.parse_args()
