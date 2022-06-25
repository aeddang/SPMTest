
import Foundation
import SwiftUI
struct SortButton: View{
    var title:String? = nil
    var text:String
    var isFocus:Bool = false
    var isFill:Bool = false
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.light,
        color: Color.app.white
    )
    var size:CGFloat = Dimen.tab.regular
    var padding:CGFloat = Dimen.margin.thin
    var bgColor:Color = Color.app.blue60
    var strokeColor:Color = Color.app.black40
    var cornerRadius:CGFloat = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.thin){
                    if self.title != nil {
                        Text(self.title!)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(textModifier.color)
                        .opacity(0.6)
                    }
                    Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(textModifier.color)
                    if self.isFill {
                        Spacer().modifier(MatchParent())
                    }
                    Image(Asset.icon.sort, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                }
                .padding(.horizontal, self.padding)
            }
            .frame(height:self.size)
            .background(self.bgColor)
            .clipShape(
                RoundedRectangle(cornerRadius: self.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: self.cornerRadius)
                        .stroke(
                            self.isFocus ? Color.app.white
                            :  self.isFill ? self.strokeColor : Color.app.blue60,
                            lineWidth: self.isFill ? 1 : 3)
                
            )
        }
    }
}
#if DEBUG
struct SortButtonButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SortButton(
                title:"test",
                text: "test",
                isFocus: true,
                isFill: true,
                bgColor: Color.app.blue70
            )
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif
