import tomllib

cfg = tomllib.load(open("../configs/utpu.toml", "rb"))

with open("../generated/generated_params.sv", "w") as f:
    f.write(f"parameter int ARRAY_SIZE = {cfg['array']['size']};\n")
    f.write(f"parameter int INPUT_DATA_WIDTH = {cfg['datatypes']['input_width']};\n")
    f.write(f"parameter int ACCUMULATOR_DATA_WIDTH = {cfg['datatypes']['accumulator_width']};\n")
