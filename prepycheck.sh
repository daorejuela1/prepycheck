#!/usr/bin/env bash
bold=$(tput bold)
function checker_print {
  if [[ $1 == "BAD" ]]
  then
	RED='\033[0;31m'
	echo -e "${RED}BAD"
  elif [[ $1 == "OK" ]]
  then
	GREEN='\033[1;32m'
	echo -e "${GREEN}OK"
  else
	YELLOW='\033[0;33m'
	echo -e "${YELLOW}WARNING"
  fi
  NC='\033[0m'
  echo -en "${NC}"
}

function check_shebang {
  echo "${bold}[[SHEBANG TEST]]"
  first_line=$(head -1 "$1")
  if [[ $first_line == "#!/usr/bin/env python3" ]]
  then
	checker_print "OK"
  elif [[ $first_line == "#!/usr/bin/python3" ]]
  then
	checker_print "OK"
  else
	checker_print "BAD"
  fi
}

function general_doctest {
  echo "${bold}[[DOCUMENTATION TEST]]"
  file_doc=$(echo "$1" | rev | cut -d "/" -f1 | rev)
  path_doc=$(echo "$1" | rev | cut -d "/" -f2- | rev)
  doc_len="$(python3 -c "import sys; sys.path.append('$path_doc'); print(__import__('$file_doc').__doc__)")"
  if [[ ${#doc_len} -gt 0 && $doc_len != "None" ]]
  then
	checker_print "OK"
  else
	checker_print "BAD"
  fi
}

function funct_pep8 {
  echo "${bold}[[STYLE TEST]]"
  style_output=$(python3 -m pep8 "$1")
  if [[ $style_output == *"not found"* ]]; then
	style_output=$(python3 -m pycodestyle "$1")
	if [[ $style_output == *"not found"* ]]; then
	  echo -n "$1 "; checker_print "WARNING"
	fi
  fi
  if [[ ${#style_output} == 0 ]]; then
	checker_print "OK"
  else
	echo "$style_output"
	checker_print "BAD"
  fi
}

function class_doc {
  echo "${bold}[[CLASS TEST]]"
  my_classes=$(grep "^class " "$1"| cut -d " " -f2 | cut -d "(" -f1)
  file_doc=$(echo "$2" | rev | cut -d "/" -f1 | rev)
  path_doc=$(echo "$2" | rev | cut -d "/" -f2- | rev)
  for class in $my_classes; do
	class_check="$(python3 -c "import sys; sys.path.append('$path_doc'); print(__import__('$file_doc').$class.__doc__)")"
  if [[ ${#class_check} -gt 0 && $class_check != "None" ]]
  then
	echo -n "$class "; checker_print "OK"
  else
	echo -n "$class "; checker_print "BAD"
  fi
  done
}

function function_doc {
  echo "${bold}[[FUNCTION TEST]]"

  file_doc=$(echo "$2" | rev | cut -d "/" -f1 | rev)
  path_doc=$(echo "$2" | rev | cut -d "/" -f2- | rev)
  for class in $my_classes; do
	my_data="$(python3 -c "import sys; sys.path.append('$path_doc'); basic=__import__('$file_doc'); print(str([ m for m in dir(basic.$class) if not m.startswith('__')])[1:-1])")"

	for func in $my_data; do
	  my_dato=$(echo "$func" | cut -d "'" -f2)
	  docperclass="$(python3 -c "import sys; sys.path.append('$path_doc'); print(__import__('$file_doc').$class.$my_dato.__doc__)")"
	  if [[ ${#docperclass} -gt 0 && $docperclass != "None" ]]
	  then
		echo -n "$my_dato "; checker_print "OK"
	  else
		echo -n "$my_dato "; checker_print "BAD"
	  fi
	done
  done

  outside_func=$(grep "^def " "$1"| cut -d " " -f2 | cut -d "(" -f1)
  for data in $outside_func; do
	my_dato=$(echo "$data" | cut -d "'" -f2)
	docpermodule="$(python3 -c "import sys; sys.path.append('$path_doc');print(__import__('$file_doc').$my_dato.__doc__)")"
	if [[ ${#docpermodule} -gt 0 && $docpermodule != "None" ]]
	then
	  echo -n "$my_dato "; checker_print "OK"
	else
	  echo -n "$my_dato "; checker_print "BAD"
	fi

  done
}

shopt -s nullglob
if [[ $# == 0 ]]; then
	iterator="*.py"
else
	iterator="$*"
fi
for file in $iterator
	do
		echo -e "*****-------- ${bold}Testing file \033[0;33m'$file'\033[0m ----------*****"
		file_name="$(echo "$file" | cut -d "." -f1)"
		check_shebang "$file"
		general_doctest "$file_name"
		funct_pep8 "$file"
		class_doc "$file" "$file_name"
		function_doc "$file" "$file_name"
	done