//=============================================================================
/// Time-management class.
/// Not yet implemented.
/// This is a built-in Unreal class and it shouldn't be modified.
///
/// Coordinated Universal Time or UCT is the world standard time 
/// representation which is independent of time zone and daylight
/// savings time.  The UCT standard supercedes the obsolete Grenwich
/// Mean Time (GMT).
///
/// UCT is technically the time on the zeroth meridian plus 12 hours.
/// For example, to convert UCT to EST (Eastern Standard Time), subtract 
/// 5 hours from UCT and then (??if dst).
///
/// By definition, UCT experiences a discontinuity when a leap second 
/// is reached. However, this discontinuity is never exposed while Unreal is
/// running, as UCT is determined at startup time, and UCT is updated
/// continuously during gameplay according to the CPU clock.
///
/// Unreal time is exposed as a long (a 64-bit signed quantity) and
/// is defined as nanoseconds elapsed since 
/// midnight (00:00:00), January 1, 1970.
///
/// For more information about UCT and time, see
///  http://www.bldrdoc.gov/timefreq/faq/faq.htm
///  http://www.boulder.nist.gov/timefreq/glossary.htm
///  http://www.jat.org/jtt/datetime.html
///  http://www.eunet.pt/ano2000/gen_8601.htm
//=============================================================================
class Time extends Object
    transient;

defaultproperties
{
}
