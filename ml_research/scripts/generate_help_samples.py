"""Generate synthetic HELP audio samples using Windows TTS."""

import pyttsx3
from pathlib import Path

def main():
    help_dir = Path(r'D:\Project\Ifaaz\kws_help_listener_ml\data\custom\help')
    help_dir.mkdir(parents=True, exist_ok=True)
    
    # Clean existing samples
    for f in help_dir.glob('*.wav'):
        f.unlink()
    
    engine = pyttsx3.init()
    
    # Get available voices
    voices = engine.getProperty('voices')
    print(f'Found {len(voices)} voices')
    
    variations = [
        'help', 'Help', 'help me', 'Help me', 
        'help please', 'I need help', 'somebody help', 
        'please help', 'can you help', 'need help',
        'help us', 'help now', 'help help', 'oh help',
    ]
    rates = [100, 130, 160, 190]
    
    count = 0
    for voice in voices[:4]:  # Use up to 4 voices
        engine.setProperty('voice', voice.id)
        print(f'Using voice: {voice.name}')
        for rate in rates:
            engine.setProperty('rate', rate)
            for text in variations:
                out_path = help_dir / f'help_synth_{count:04d}.wav'
                engine.save_to_file(text, str(out_path))
                engine.runAndWait()
                count += 1
                print(f'[{count}] Created: {out_path.name} - "{text}" @ rate={rate}')
                if count >= 60:
                    break
            if count >= 60:
                break
        if count >= 60:
            break
    
    print(f'\nTotal HELP samples created: {count}')

if __name__ == "__main__":
    main()
