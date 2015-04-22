#Holos-AS
Holos-AS is a result of my earlier work in ActionScript, developing a framework for organizing, simplifying, and 
automating many of the tasks I was facing in the building of various Flash-based applications.  Due to the collapse
of Flash as a viable web platform, work on this library was halted and my energies shifted to JavaScript related 
endeavors.

Holos-AS consists of three main parts:
1: Deep Address: automates and externalizes the routing of the hierarchical navigational (deep-linking) 
structure and logic of a site.
2: AutoParse: automatically parses XML into Value Objects (VOs) as a function of introspection on the VO classes
3: Logic: Various classes for maintaining complex state logic.


##Deep Address
PATH: /src/sz/holos/site/DeepAddress.as
MAIN GOAL : To automate and externalize the management and wiring of the hierarchical navigational (deep-linking)
structure and logic of a site.  This aids in removing human error and tedium in ad hoc wiring this structure by hand,
and speeds up production by placing the development work in the XML model, with its ready and easy hierarchical
structure.
DeepAddress combines SWFAddressManager---to integrate deep-linking---with the URI or path tree/space modeling
in HoloModel to provide an automated, option-space or navigation model for the hierarchical URL path (and data)
structural requirements of a site.


##AutoParse
PATH: /src/sz/holos/config/AutoParse.as
DESCRIPTION
AutoParse is a static class for automatically parsing XML into various data holders (e.g. value objects or arrays).
It does this very flexibly by a correspondence between both (1) the names of the properties of the ValueObject
subclass (VO herein) and (2) the names of either the first-level attributes or child nodes (of the root XML node(s)
passed into the AutoParse.vo() function).
BENEFITS: One benefit of this approach is that it keeps your naming convention clean between the xml nodes or attributes 
and their corresponding names in the VOs.  And it keeps the xml structure coherent and consistent, as well, such that 
once you know the system, it becomes very easy to track down the XML data source of the variables, rather than having 
things show up in undefined places. Another benefit is that it enables a certain predictable flexibility in changes to 
the XML after the parser/VO correspondence has been established. This is because the parser does not care whether you 
use child nodes or attributes in this name-correspondence between VO and XML.  And it doesn't care if you sometimes use 
one, and sometimes another (say if you suddenly discover that you need a CDATA node rather than an attribute string), 
for data parsed into instances of the same VO. All sorts of mixtures and variations can be used across the XML nodes 
corresponding to the main VO class to be parsed.  So long as the naming correspondence between the VO properties and 
the first-level XML data exists (barring further criteria for the higher-level functionality available in AutoParse). 
All of this makes debugging easier, and the rigour of the naming correspondence and hierarchical ordering conventions, 
etc.., is a small price to pay for the benefits involved of the increase in order and not needing to write any parsers, 
for the most common needs.


##Logic
PATH: /src/sz/holos/logic
The logic classes focus on management of state is an asynchronous application with complex interaction logic.


