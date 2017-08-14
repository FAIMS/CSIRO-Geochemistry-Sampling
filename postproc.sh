#!/usr/bin/env bash

cd module

string="
        <select1 ref=\"Entity_Types\">
          <label>{Entity_Types}<\/label>
          <item>
            <label>Options not loaded<\/label>
            <value>Options not loaded<\/value>
          <\/item>
        <\/select1>"
replacement="
        <group ref=\"Colgroup_1\" faims_style=\"orientation\">
          <label\/>
          <group ref=\"Col_0\" faims_style=\"even\">
            <label\/>
            <select1 ref=\"Entity_Types\">
              <label>{Entity_Types}<\/label>
              <item>
                <label>Options not loaded<\/label>
                <value>Options not loaded<\/value>
              <\/item>
            <\/select1>
          <\/group>
          <group ref=\"Col_1\" faims_style=\"even\">
            <label\/>
            <select1 ref=\"Select_User\">
              <label>{Select_User}<\/label>
              <item>
                <label>Options not loaded<\/label>
                <value>Options not loaded<\/value>
              <\/item>
            <\/select1>
          <\/group>
        <\/group>"
perl -0777 -i.original -pe "s/$string/$replacement/igs" ui_schema.xml

string="
              <Entity_Types\/>"
replacement="
              <Colgroup_1>
                <Col_0>
                  <Entity_Types\/>
                <\/Col_0>
                <Col_1>
                  <Select_User\/>
                <\/Col_1>
              <\/Colgroup_1>
              <Select_User\/>"
perl -0777 -i.original -pe "s/$string/$replacement/igs" ui_schema.xml

cat << EOF >> ui_styling.css
.readonly {
  color: #B2B2B2;
}
EOF

cat << EOF >> english.0.properties
All=All
Create_Record=Create Record
No_Duplicates_Found=No Duplicates Found
Select_User=Select User
Valid_Starting_Sample_ID=Valid Starting Sample ID
Eh=Eh
pH=pH
Add_New_Eh=Add New Eh
Add_New_pH=Add New pH
Please_Fill_In_PH=Please fill in an pH value
Please_Fill_In_EH=Please fill in an Eh value
Duplicate_IDs_Found=Duplicate IDs found
Press_To_Delete=Press OK to Delete this
EOF

echo ".fixedheightfive { height: 250px; }" >> ui_styling.css

rm ui_schema.xml.original
