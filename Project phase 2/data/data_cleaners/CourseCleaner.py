import pandas as pd
# This program cleans the data for courses by separating the course abbreviation + catalog # from the course name.
# The abbreviation + catalog # is then saved as the course code.
# Program by Rise Akizaki

# absolute filepath.
file_path = r"C:\Users\Work\Documents\GitHub\Study_Buddy_hub\Project phase 2\data\usm_courses.csv"
df = pd.read_csv(file_path)

file_height = len(df)

# Separates course abbreviation + catalog # from the course name, and saves it as the course code
def CleanData():
    for i in range (file_height):
        name_length = len(df.loc[i, 'course_name'])
        course_code = df.loc[i,'course_name'][:3] + df.loc[i,'course_name'][4:7] # course code is course abr + catalog #. Removes whitespace
        df.loc[i,'course_code'] = course_code # adds saved course code to the code column
        df.loc[i,'course_name'] = df.loc[i,'course_name'][10:name_length] # removes course code from course name
    print("Finished cleaning course data")

CleanData()

output_path = "cleaned_courses.csv"
df.to_csv(output_path, index = False) # index = False prevents indices from being the first column
print("Copy of cleaned courses saved to " + output_path)
