
how to install ANT:
	
	download http://ant.apache.org/bindownload.cgi
	
	unpack into directory that does not contain spaces (!)
	
	set environment variable FLEX_HOME to flex installation directory
	
	set environment variable ANT_HOME to ANT installation directory
	
	add %ANT_HOME%\bin to your PATH
	
	for instance:
		ANT_HOME  E:\ant\apache-ant-1.8.3
		FLEX_HOME E:\FlashDevelop\Tools\flexsdk
		Path      (...)C:\Java\jdk1.6.0_27\bin;%ANT_HOME%\bin
	
	see if it works by typing in command line: C:\>ant
	
	copy flexTasks.jar from FLEX_HOME\ant to ANT_HOME\lib
	
	download http://sourceforge.net/projects/ant-contrib/files/ant-contrib/1.0b3/ant-contrib-1.0b3-bin.zip/download
	
	copy ant-contrib-1.0b3.jar to ANT_HOME\lib
	
use ANT via command line:
	
	C:\>ant -buildfile "F:\SaladoPlayer\ant\build.xml" "SaladoPlayer"
	(here SaladoPlayer is name of task defined in build.xml file)
	
when using FlashDevelop:
	
	download plugin http://code.google.com/p/fd-ant-plugin/downloads/list
	place unpacked *.dll in Flashdevelop plugins directory
	in Program Settings configure AntPlugin and set ANT installation directory
	restart Flashdevelop
	open "Ant window" and point to build.xml file
	
For more details see comments in build.xml file
