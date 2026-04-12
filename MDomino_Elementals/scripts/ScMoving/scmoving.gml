// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function ScMoving()
{

	if !place_meeting(x+1,y,oWall)
	{
		x+=64
		return true
	}

	if !place_meeting(x-1,y,oWall)
	{
		x-=64
		return true
	}

			if !place_meeting(x,y+1,oWall)
			{
				y+=64
				return true
			}

			if !place_meeting(x,y-1,oWall)
			{
				y-=64
				return true
			}

}