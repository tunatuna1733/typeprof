require "rbs"

module TypeProf::Core
  class Signatures
    def self.build(genv)
      genv.rbs_builder.env.declarations.each do |decl|
        declaration(genv, decl)
      end
      genv.define_all
    end

    def self.declaration(genv, decl)
      case decl
      when RBS::AST::Declarations::Class
        name = decl.name
        cpath = name.namespace.path + [name.name]
        # TODO: decl.type_params
        # TODO: decl.super_class.args
        genv.resolve_cpath(cpath).module_decls << decl
        genv.resolve_const(cpath).add_decl(decl, Source.new(Type::Module.new(cpath)))
        superclass = decl.super_class
        if superclass
          superclass_cpath = superclass.name.namespace.path + [superclass.name.name]
        else
          superclass_cpath = []
        end
        genv.resolve_cpath(cpath).set_superclass_cpath(superclass_cpath)
        members(genv, cpath, decl.members)
      when RBS::AST::Declarations::Module
        name = decl.name
        cpath = name.namespace.path + [name.name]
        genv.resolve_cpath(cpath).module_decls << decl
        genv.resolve_const(cpath).add_decl(decl, Source.new(Type::Module.new(cpath)))
        members(genv, cpath, decl.members)
      when RBS::AST::Declarations::Constant
        name = decl.name
        cpath = name.namespace.path + [name.name]
        vtx = type_to_vtx(genv, decl, decl.type, {})
        genv.resolve_const(cpath).add_decl(decl, vtx)
      when RBS::AST::Declarations::AliasDecl
      when RBS::AST::Declarations::TypeAlias
        # TODO: check
      when RBS::AST::Declarations::Interface
      when RBS::AST::Declarations::Global
        vtx = type_to_vtx(genv, decl, decl.type, {})
        genv.resolve_gvar(decl.name).add_decl(decl, vtx)
      else
        raise "unsupported: #{ decl.class }"
      end
    end

    def self.members(genv, cpath, members)
      members.each do |member|
        case member
        when RBS::AST::Members::MethodDefinition
          mid = member.name
          # TODO: もしすでに MethodDef があったら、
          # この RBS を前提に再解析する
          if member.singleton?
            mdecl = MethodDeclOld.new(cpath, true, mid, member)
            genv.add_method_decl(mdecl)
          end
          if member.instance?
            mdecl = MethodDeclOld.new(cpath, false, mid, member)
            genv.add_method_decl(mdecl)
          end
        when RBS::AST::Members::Include
          name = member.name
          mod_cpath = name.namespace.path + [name.name]
          genv.add_module_include(cpath, mod_cpath)
        when RBS::AST::Members::Extend
        when RBS::AST::Members::Public
        when RBS::AST::Members::Private
        when RBS::AST::Members::Alias
          if member.singleton?
            malias = MethodAlias.new(cpath, true, member.new_name, member.old_name, member)
            genv.add_method_alias(malias)
          end
          if member.instance?
            malias = MethodAlias.new(cpath, false, member.new_name, member.old_name, member)
            genv.add_method_alias(malias)
          end
        when
          RBS::AST::Declarations::TypeAlias,
          RBS::AST::Declarations::Constant,
          RBS::AST::Declarations::Class,
          RBS::AST::Declarations::Module,
          RBS::AST::Declarations::Interface

          declaration(genv, member)
        else
          raise "unsupported: #{ member.class }"
        end
      end
    end

    def self.type_to_vtx(genv, node, type, param_map)
      vtx = Vertex.new("type_to_vtx", node)
      type_to_vtx0(genv, node, type, vtx, param_map)
      vtx
    end

    def self.type_to_vtx0(genv, node, type, vtx, param_map)
      case type
      when RBS::Types::Alias
        type_to_vtx0(genv, node, genv.rbs_builder.expand_alias(type.name), vtx, param_map)
      when RBS::Types::Union
        type.types.each do |ty|
          type_to_vtx0(genv, node, ty, vtx, param_map)
        end
      when RBS::Types::Intersection
        Source.new # TODO
      when RBS::Types::ClassSingleton
        Source.new # TODO
      when RBS::Types::ClassInstance
        name = type.name
        cpath = name.namespace.path + [name.name]
        case cpath
        when [:Array]
          raise if type.args.size != 1
          elem = type.args.first
          elem_vtx = type_to_vtx(genv, node, elem, param_map)
          Source.new(Type::Array.new(nil, elem_vtx, Type.ary)).add_edge(genv, vtx)
        when [:Set]
          elem = type.args.first
          elem_vtx = type_to_vtx(genv, node, elem, param_map)
          Source.new(Type::Array.new(nil, elem_vtx, Type::Instance.new([:Set]))).add_edge(genv, vtx)
        when [:Hash]
          raise if type.args.size != 2
          key_vtx = type_to_vtx(genv, node, type.args[0], param_map)
          val_vtx = type_to_vtx(genv, node, type.args[1], param_map)
          Source.new(Type::Hash.new(nil, key_vtx, val_vtx, Type.hsh)).add_edge(genv, vtx)
        else
          Source.new(Type::Instance.new(cpath)).add_edge(genv, vtx)
        end
      when RBS::Types::Tuple
        unified_elem = Vertex.new("ary-unified", node)
        elems = type.types.map do |type|
          nvtx = type_to_vtx(genv, node, type, param_map)
          nvtx.add_edge(genv, unified_elem)
          nvtx
        end
        Source.new(Type::Array.new(elems, unified_elem, Type.ary)).add_edge(genv, vtx)
      when RBS::Types::Interface
        # TODO...
      when RBS::Types::Bases::Bool
        Source.new(Type.true, Type.false).add_edge(genv, vtx)
      when RBS::Types::Bases::Nil
        Source.new(Type.nil).add_edge(genv, vtx)
      when RBS::Types::Bases::Self
        param_map[:__self].add_edge(genv, vtx)
      when RBS::Types::Bases::Void
        Source.new(Type.obj).add_edge(genv, vtx) # TODO
      when RBS::Types::Bases::Any
        Source.new().add_edge(genv, vtx) # TODO
      when RBS::Types::Bases::Top
        Source.new().add_edge(genv, vtx)
      when RBS::Types::Bases::Bottom
        Source.new(Type::Bot.new).add_edge(genv, vtx)
      when RBS::Types::Variable
        if param_map[type.name]
          param_map[type.name].add_edge(genv, vtx)
        else
          #puts "unknown type param: #{ type.name }"
        end
      when RBS::Types::Optional
        type_to_vtx0(genv, node, type.type, vtx, param_map)
        Source.new(Type.nil).add_edge(genv, vtx)
      when RBS::Types::Literal
        ty = case type.literal
        when ::Symbol
          Type::Symbol.new(type.literal)
        when ::Integer then Type.int
        when ::String then Type.str
        when ::TrueClass then Type.true
        when ::FalseClass then Type.false
        else
          raise "unknown RBS literal: #{ type.literal.inspect }"
        end
        Source.new(ty).add_edge(genv, vtx)
      else
        raise "unknown RBS type: #{ type.class }"
      end
    end
  end
end