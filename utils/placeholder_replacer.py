import os
import re

def replace_placeholders_in_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    def replace_match(match):
        env_var = match.group(1)
        value = os.getenv(env_var, f'#{env_var}#')
        print(f'Replacing key: "{env_var}", with value: "{value}"')
        return value

    replaced_content = re.sub(r'#\{(.*?)\}#', replace_match, content)

    with open(file_path, 'w') as file:
        file.write(replaced_content)